
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

for engine, _ of test.db

  describe "db.user #{engine}", ->
    return unless test.tags.db

    they 'requires host, hostname, username', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @db.user
          port: 5432
          engine: engine
          admin_username: test.db[engine].admin_username
          admin_password: test.db[engine].admin_password
        .should.be.rejectedWith
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors were found in the configuration of action `db.user`:'
            '#/required config must have required property \'password\';'
            '#/required config must have required property \'username\';'
            'module://@nikitajs/db/query#/definitions/db/required config must have required property \'host\'.'
          ].join ' '
    
    they 'requires admin_username, password, username', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @db.user
          host: 'localhost'
          port: 5432
          engine: engine
          admin_password: test.db[engine].admin_password
        .should.be.rejectedWith
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors were found in the configuration of action `db.user`:'
            '#/required config must have required property \'password\';'
            '#/required config must have required property \'username\';'
            'module://@nikitajs/db/query#/definitions/db/required config must have required property \'admin_username\'.'
          ].join ' '

    they 'add new user', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.user.remove 'test_user_1_user'
        {$status} = await @db.user
          username: 'test_user_1_user'
          password: 'test_user_1_password'
        $status.should.be.true()
        {$status} = await @db.user
          username: 'test_user_1_user'
          password: 'test_user_1_password'
        $status.should.be.false()
        {exists} = await @db.user.exists
          username: 'test_user_1_user'
        exists.should.be.true()
        await @db.user.remove 'test_user_1_user'

    they 'change password', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'test_user_2_db'
        await @db.user.remove 'test_user_2_user'
        await @db.user
          username: 'test_user_2_user'
          password: 'test_user_2_invalid'
        await @db.database
          database: 'test_user_2_db'
          user: 'test_user_2_user'
        await @db.user
          username: 'test_user_2_user'
          password: 'test_user_2_valid'
        await @db.query
          engine: engine
          host: test.db[engine].host
          port: test.db[engine].port
          database: 'test_user_2_db'
          admin_username: 'test_user_2_user'
          admin_password: 'test_user_2_valid'
          command: switch engine
            when 'mariadb', 'mysql'
              'show tables'
            when 'postgresql'
              '\\dt'
        await @db.database.remove 'test_user_2_db'
        await @db.user.remove 'test_user_2_user'
