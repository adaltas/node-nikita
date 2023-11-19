
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'db.schema.exists postgres', ->
  return unless test.tags.db
  return unless test.db.postgresql

  they 'output exists', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'schema_exists_0'
      await @db.database 'schema_exists_0'
      {exists} = await @db.schema.exists
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      exists.should.be.false()
      await @db.schema
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      {exists} = await @db.schema.exists
        schema: 'schema_exists_0'
        database: 'schema_exists_0'
      exists.should.be.true()
      await @db.database.remove 'schema_exists_0'
