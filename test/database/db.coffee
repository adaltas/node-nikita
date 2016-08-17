
mecano = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'

describe 'db.database', ->

  config = test.config()

  they 'add new database (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_0'
    .database.db.add
      database: 'postgres_db_0'
    .database.db.remove 'postgres_db_0'
    .then next
    
  they 'status not modified new database (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_1'
    .database.db.add
      database: 'postgres_db_1'
    .database.db.add
      database: 'postgres_db_1'
    , (err, status) ->
      status.should.be.false() unless err
    .database.db.remove 'postgres_db_1'
    .then next

  they 'add new database and add existing user to it (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_3'
    .database.user.remove 'postgres_user_3'
    .database.user.add
      username: 'postgres_user_3'
      password: 'postgres_user_3'
    .database.db.add
      database: 'postgres_db_3'
      user: 'postgres_user_3'
    .execute
      cmd: db.cmd(config.db.postgres, "SELECT datacl FROM pg_database WHERE  datname = 'postgres_db_3'") + " | grep 'postgres_user_3'"
    , (err, status) ->
      status.should.be.true() unless err
    .database.db.remove
      database: 'postgres_db_3'
      always: true
    .database.user.remove
      username: "postgres_user_3"
      always: true
    .then next

  they 'add new database and add not-existing user to it (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_4'
    .database.user.remove 'postgres_user_4'
    .database.db.add
      database: 'postgres_db_4'
      user: 'postgres_user_4'
    .execute
      cmd: db.cmd(config.db.postgres, "SELECT datacl FROM  pg_database WHERE  datname = 'postgres_db_4'") + " | grep 'postgres_user_4'"
      code_skipped: 1
    , (err, status) ->
      status.should.be.false() unless err
    .database.db.remove
      database: 'postgres_db_4'
      always: true
    .database.user.remove
      username: "postgres_user_4"
      always: true
    .then next
