
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'db.schema.remove postgres', ->
  return unless test.tags.db
  return unless test.db.postgresql

  they 'does not exists', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'schema_remove_0'
      await @db.database 'schema_remove_0'
      {$status} = await @db.schema.remove
        schema: 'schema_remove_0'
        database: 'schema_remove_0'
      $status.should.be.false()
      await @db.database.remove 'schema_remove_0'

  they 'output exists', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'schema_remove_1'
      await @db.database 'schema_remove_1'
      await @db.schema
        schema: 'schema_remove_1'
        database: 'schema_remove_1'
      {$status} = await @db.schema.remove
        schema: 'schema_remove_1'
        database: 'schema_remove_1'
      $status.should.be.true()
      {$status} = await @db.schema.remove
        schema: 'schema_remove_1'
        database: 'schema_remove_1'
      $status.should.be.false()
      await @db.database.remove 'schema_remove_1'
