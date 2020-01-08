
nikita = require '@nikitajs/core'
{cmd} = require '../src/query'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

for engine, _ of db

  describe "db.user #{engine}", ->

    they 'validate options', ({ssh}) ->
      nikita
        ssh: ssh
      .db.user
        port: 5432
        engine: engine
        admin_username: db[engine].admin_username
        admin_password: db[engine].admin_password
        relax: true
      , (err) ->
        err.message.should.eql 'Missing option: "host"'
      .db.user
        host: 'localhost'
        port: 5432
        engine: engine
        admin_password: db[engine].admin_password
        relax: true
      , (err) ->
        err.message.should.eql 'Missing option: "admin_username"'
      .promise()

    they 'add new user', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      .db.user.remove 'test_user_1_user'
      .db.user
        username: 'test_user_1_user'
        password: 'test_user_1_password'
      , (err, {status}) ->
        status.should.be.true() unless err
      .db.user
        username: 'test_user_1_user'
        password: 'test_user_1_password'
      , (err, {status}) ->
        status.should.be.false() unless err
      .db.user.exists
        username: 'test_user_1_user'
      , (err, exists) ->
        throw Error 'User not created' if not err and not exists
      .db.user.remove 'test_user_1_user'
      .promise()

    they 'change password', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
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
        cmd: cmd
          engine: engine
          host: db[engine].host
          port: db[engine].port
          database: 'test_user_2_db'
          admin_username: 'test_user_2_user'
          admin_password: 'test_user_2_valid'
          , switch engine
            when 'mariadb', 'mysql'
              'show tables'
            when 'postgresql'
              '\\dt'
      .db.database.remove 'test_user_2_db'
      .db.user.remove 'test_user_2_user'
      .promise()
