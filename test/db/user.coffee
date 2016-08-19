
mecano = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'

describe 'db.user', ->

  config = test.config()

  they 'validate options', (ssh, next) ->
    mecano
      ssh: ssh
    .db.user.add
      port: 5432
      engine: 'postgres'
      admin_username: config.db.postgres.admin_username
      admin_password: config.db.postgres.admin_password
      relax: true
    , (err) ->
      err.message.should.eql 'Missing option: "host"'
    .db.user.add
      host: 'postgres'
      port: 5432
      engine: 'postgres'
      admin_password: config.db.postgres.admin_password
      relax: true
    , (err) ->
      err.message.should.eql 'Missing option: "admin_username"'
    .then next
  
  they 'add new user (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.user.remove 'test_1'
    .db.user.add
      username: 'test_1'
      password: 'test_1'
    .execute 
      cmd: db.cmd(config.db.postgres, "\\du") + " | grep 'test_1'"
      code_skipped: 2
    .db.user.remove 'test_1'
    .then next

  they 'add already existing user with new password(POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.database.remove 'test_db_2'
    .db.user.remove 'test_2'
    .db.user.add
      username: 'test_2'
      password: 'test_1'
    .db.database.add
      database: 'test_db_2'
      user: 'test_2'
    .db.user.add
      username: 'test_2'
      password: 'test_2'
    .execute
      cmd: db.cmd 
        engine: config.db.postgres.engine
        host: config.db.postgres.host
        port: config.db.postgres.port
        database: 'test_db_2'
        username: 'test_2'
        password: 'test_2'
        , '\\l'
    .db.database.remove 'test_db_2'
    .db.user.remove 'test_2'
    .then next
