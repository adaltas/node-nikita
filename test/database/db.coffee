
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
mecano = require '../../src'
postgres = require '../../src/misc/database'
test = require '../test'
they = require 'ssh2-they'

describe 'database db operations', ->

  scratch = test.scratch @
  config = test.config()

  they 'add new database (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_0;'"
      code_skipped: 1
    .database.db.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_0'
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_0;'"
      code_skipped: 1
    .then next
    
  they 'status not modified new database (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
      code_skipped: 1
    .database.db.add
      engine: 'postgres'
      host: 'postgres'
      port: 5432
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_1'
    .database.db.add
      engine: 'postgres'
      host: 'postgres'
      port: 5432
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_1'
    , (err, status) ->
      return next err if err
      status.should.be.false()
      mecano
        ssh:ssh
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
        code_skipped: 1
    .then next

  they 'add new database and add existing user to it (POSTGRES)', (ssh, next) ->
    opts =
      engine: 'postgres'
      host: 'postgres'
      name: config.database.admin_user
      password: config.database.admin_password
      port: 5432
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
      code_skipped: 1
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS postgres_user_3;'"
      code_skipped: 1
    .database.user.add
      engine: 'postgres'
      host: 'postgres'
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      port: 5432
      name: 'postgres_user_3'
      password: 'postgres_user_3'
    .database.db.add
      engine: 'postgres'
      host: 'postgres'
      port: 5432
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_1'
      user: 'postgres_user_3'
    .execute
      cmd: "#{postgres.wrap opts} -d postgres_db_1 -tAc \"SELECT datacl FROM  pg_database WHERE  datname = 'postgres_db_1'\" | grep 'postgres_user_3'"
    , (err, status) ->
      return next err if err
      status.should.be.true()
      mecano
        ssh:ssh
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
        code_skipped: 1
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS postgres_user_3;'"
        code_skipped: 1
    .then next

  they 'add new database and add not-existing user to it (POSTGRES)', (ssh, next) ->
    opts =
      engine: 'postgres'
      host: 'postgres'
      name: config.database.admin_user
      password: config.database.admin_password
      port: 5432
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_4;'"
      code_skipped: 1
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS postgres_user_4;'"
      code_skipped: 1
    .database.db.add
      engine: 'postgres'
      host: 'postgres'
      port: 5432
      admin_name: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_4'
      user: 'postgres_user_4'
    .execute
      cmd: "#{postgres.wrap opts} -d postgres_db_4 -tAc \"SELECT datacl FROM  pg_database WHERE  datname = 'postgres_db_4'\" | grep 'postgres_user_4'"
      code_skipped: 1
    , (err, status) ->
      return next err if err
      status.should.be.false()
      mecano
        ssh:ssh
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_4;'"
        code_skipped: 1
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER IF EXISTS postgres_user_4;'"
        code_skipped: 1
    .then next
