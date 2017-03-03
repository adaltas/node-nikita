
nikita = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'
each = require 'each'

config = test.config()
return if config.disable_db
for engine, _ of config.db

  describe "db.user #{engine}", ->

    they 'validate options', (ssh, next) ->
      nikita
        ssh: ssh
      .db.user
        port: 5432
        engine: engine
        admin_username: config.db[engine].admin_username
        admin_password: config.db[engine].admin_password
        relax: true
      , (err) ->
        err.message.should.eql 'Missing option: "host"'
      .db.user
        host: 'localhost'
        port: 5432
        engine: engine
        admin_password: config.db[engine].admin_password
        relax: true
      , (err) ->
        err.message.should.eql 'Missing option: "admin_username"'
      .then next
    
    they 'add new user', (ssh, next) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.user.remove 'test_user_1_user'
      .db.user
        username: 'test_user_1_user'
        password: 'test_user_1_password'
      , (err, status) ->
        status.should.be.true() unless err
      .db.user
        username: 'test_user_1_user'
        password: 'test_user_1_password'
      , (err, status) ->
        status.should.be.false() unless err
      .db.user.exists
        username: 'test_user_1_user'
      , (err, exists) ->
        throw Error 'User not created' if not err and not exists
      .db.user.remove 'test_user_1_user'
      .then next

    they 'change password', (ssh, next) ->
      sql_list_tables = switch engine
        when 'mysql'
          'show tables'
        when 'postgres'
          '\\dt'
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'test_user_2_db'
      .db.user.remove 'test_user_2_user'
      .db.user
        username: 'test_user_2_user'
        password: 'test_user_2_invalid'
      .db.database
        database: 'test_user_2_db'
        user: 'test_user_2_user'
      .db.user
        username: 'test_user_2_user'
        password: 'test_user_2_valid'
      .system.execute
        cmd: db.cmd 
          engine: engine
          host: config.db[engine].host
          port: config.db[engine].port
          database: 'test_user_2_db'
          username: 'test_user_2_user'
          password: 'test_user_2_valid'
          , sql_list_tables
      .db.database.remove 'test_user_2_db'
      .db.user.remove 'test_user_2_user'
      .then next
