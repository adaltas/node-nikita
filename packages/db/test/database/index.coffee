
import nikita from '@nikitajs/core'
import utils from '@nikitajs/db/utils'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

for engine, _ of test.db then do (engine) ->

  describe "db.database #{engine}", ->
    return unless test.tags.db

    they 'database as an argument', ({ssh}) ->
      {exists} = await nikita
        $ssh: ssh
        db: test.db[engine]
      .db.database.remove 'db_create_0'
      .db.database 'db_create_0'
      .db.database.exists 'db_create_0'
      exists.should.be.true()

    they 'output `$status`', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'db_create_1'
        {$status} = await @db.database 'db_create_1'
        $status.should.be.true()
        {$status} = await @db.database 'db_create_1'
        $status.should.be.false()
        await @db.database.remove 'db_create_1'

    describe 'user', ->

      they 'which is existing', ({ssh}) ->
        nikita
          $ssh: ssh
          db: test.db[engine]
        , ->
          await @db.database.remove 'db_create_3'
          await @db.user.remove 'db_create_user_3'
          await @db.user
            username: 'db_create_user_3'
            password: 'db_create_user_3'
          await @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          # Todo: why not using nikita.user.exists ?
          {$status: user_exists} = await @execute
            command: switch engine
              when 'mariadb', 'mysql' then utils.db.command(test.db[engine], database: 'mysql', "SELECT user FROM db WHERE db='db_create_3';") + " | grep 'db_create_user_3'"
              when 'postgresql' then utils.db.command(test.db[engine], database: 'db_create_3', '\\l') + " | egrep '^db_create_user_3='"
          user_exists.should.be.true()
          await @db.database.remove 'db_create_3'
          await @db.user.remove 'db_create_user_3'

      they 'output `$status`', ({ssh}) ->
        nikita
          $ssh: ssh
          db: test.db[engine]
        , ->
          await @db.database.remove 'db_create_3'
          await @db.user.remove 'db_create_user_3'
          await @db.user
            username: 'db_create_user_3'
            password: 'db_create_user_3'
          await @db.database
            database: 'db_create_3'
          {$status} = await @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          $status.should.be.true()
          {$status} = await @db.database
            database: 'db_create_3'
            user: 'db_create_user_3'
          $status.should.be.false()
          await @db.database.remove 'db_create_3'
          await @db.user.remove 'db_create_user_3'

      they 'which is not existing', ({ssh}) ->
        nikita
          $ssh: ssh
          db: test.db[engine]
        , ->
          try
            await @db.database.remove 'db_create_4'
            await @db.user.remove 'db_create_user_4'
            await @db.database
              database: 'db_create_4'
              user: 'db_create_user_4'
            throw Error 'Oh no'
          catch err
            err.message.should.eql 'DB user does not exists: db_create_user_4'
          finally
            await @db.database.remove 'db_create_4'
            await @db.user.remove 'db_create_user_4'
