
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

for engine, _ of test.db

  describe "db.database.exists #{engine}", ->
    return unless test.tags.db

    they 'database missing', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ({tools: {status}}) ->
        {exists} = await @db.database.exists database: 'test_database_exists_0_db'
        exists.should.be.false()
        {exists} = await @db.database.exists 'test_database_exists_0_db'
        exists.should.be.false()
        status().should.be.false()

    they 'database exists', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ({tools: {status}}) ->
        await @db.database.remove 'test_database_exists_1_db', $shy: true
        await @db.database 'test_database_exists_1_db', $shy: true
        {exists} = await @db.database.exists database: 'test_database_exists_1_db'
        exists.should.be.true()
        {exists} = await @db.database.exists 'test_database_exists_1_db'
        exists.should.be.true()
        await @db.database.remove 'test_database_exists_1_db', $shy: true
        status().should.be.false()
