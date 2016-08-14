
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

  they 'add new schema with no owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_0;'"
      code_skipped: 1
    .database.db.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_0'
    .database.schema.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      schema: 'postgres_schema_0'
      database: 'postgres_db_0'
    , (err, status) ->
      return next err if err
      status.should.be.true()
    .then (err) ->
      @
      .execute
        cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_0;'"
        code_skipped: 1
      .then next

  they 'add new schema with not existing owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
      code_skipped: 1
    .database.db.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_1'
    .database.schema.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      schema: 'postgres_schema_1'
      database: 'postgres_db_1'
      owner: 'Johny'
      relax: true
    , (err, status) ->
      err.message.should.eql 'Owner Johny does not exists'
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
      code_skipped: 1
      always: true
    .then next

  they 'add new schema with existing owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_2;'"
      code_skipped: 1
    .database.user.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      name: 'mecano'
      password: 'mecano'
    .database.db.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_2'
      user: 'mecano'
    .database.schema.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      schema: 'postgres_schema_2'
      database: 'postgres_db_2'
      owner: 'mecano'
    , (err, status) ->
      status.should.be.true() unless err
    mecano
      ssh: ssh
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_1;'"
      code_skipped: 1
      always: true
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER mecano;'"
      code_skipped: 1
      always: true
    .then next

  they 'add new schema with no owner (not existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
    .database.schema.add
      engine: 'postgres'
      port: 5432
      host: 'postgres'
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      schema: 'postgres_schema_4'
      database: 'postgres_db_4'
      relax: true
    , (err, status) ->
      err.message.should.eql 'Database does not exist postgres_db_4'
      status.should.be.false()
    .then next

  they.only 'add new schema after adding database and user', (ssh, next) ->
    mecano
      ssh: ssh
      debug: true
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user} -d  postgres_db_5 -c 'DROP SCHEMA postgres_schema_5;'"
      relax: true
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP DATABASE postgres_db_5;'"
      relax: true
    .execute
      cmd: "PGPASSWORD=#{config.database.admin_password} psql -h postgres -U #{config.database.admin_user}  -c 'DROP USER mecano_test_5;'"
      relax: true
    .database.user.add
      host: 'postgres'
      port: 5432
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      name: 'mecano_test_5'
      password: 'test'
      engine: 'postgres'
    .database.db.add
      host: 'postgres'
      port: 5432
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      engine: 'postgres'
      user: 'mecano_test_5'
      database: 'postgres_db_5'
    .database.schema.add
      host: 'postgres'
      port: 5432
      admin_username: config.database.admin_user
      admin_password: config.database.admin_password
      database: 'postgres_db_5'
      schema: 'postgres_schema_5'
      owner: 'mecano_test_5'
      engine: 'postgres'
    , (err, status) ->
      status.should.be.true() unless err
    .then next
