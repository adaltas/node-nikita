
nikita = require '@nikitajs/engine/src'
{command} = require '../src/query'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

for engine, _ of db

  describe "db.user #{engine}", ->

    they 'validate options', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @db.user
          port: 5432
          engine: engine
          admin_username: db[engine].admin_username
          admin_password: db[engine].admin_password
        .should.be.rejectedWith
          message: 'NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors where found in the configuration of action `db.user`: #/required config should have required property \'host\'; #/required config should have required property \'password\'; #/required config should have required property \'username\'.'
        @db.user
          host: 'localhost'
          port: 5432
          engine: engine
          admin_password: db[engine].admin_password
        .should.be.rejectedWith
          message: 'NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors where found in the configuration of action `db.user`: #/required config should have required property \'admin_username\'; #/required config should have required property \'password\'; #/required config should have required property \'username\'.'

    they 'add new user', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      , ->
        @db.user.remove 'test_user_1_user'
        {status} = await @db.user
          username: 'test_user_1_user'
          password: 'test_user_1_password'
        status.should.be.true()
        {status} = await @db.user
          username: 'test_user_1_user'
          password: 'test_user_1_password'
        status.should.be.false()
        {exists} = await @db.user.exists
          username: 'test_user_1_user'
        exists.should.be.true()
        @db.user.remove 'test_user_1_user'

    they 'change password', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      , ->
        @db.database.remove 'test_user_2_db'
        @db.user.remove 'test_user_2_user'
        @db.user
          username: 'test_user_2_user'
          password: 'test_user_2_invalid'
        @db.database
          database: 'test_user_2_db'
          user: 'test_user_2_user'
        @db.user
          username: 'test_user_2_user'
          password: 'test_user_2_valid'
        @db.query
          engine: engine
          host: db[engine].host
          port: db[engine].port
          database: 'test_user_2_db'
          admin_username: 'test_user_2_user'
          admin_password: 'test_user_2_valid'
          command: switch engine
            when 'mariadb', 'mysql'
              'show tables'
            when 'postgresql'
              '\\dt'
        @db.database.remove 'test_user_2_db'
        @db.user.remove 'test_user_2_user'
