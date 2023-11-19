
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

for engine, _ of test.db

  describe "db.database.wait #{engine}", ->
    return unless test.tags.db

    they 'is already created', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'db_wait_1'
        await @db.database 'db_wait_0'
        {$status} = await @db.database.wait 'db_wait_0'
        $status.should.be.false()
        await @db.database.remove 'db_wait_0'

    they 'is not yet created', ({ssh}) ->
      setTimeout ->
        nikita
          $ssh: ssh
          db: test.db[engine]
        .db.database 'db_wait_1'
      , 200
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'db_wait_1'
        {$status} = await @db.database.wait 'db_wait_1'
        $status.should.be.true()
        await @db.database.remove 'db_wait_1'
