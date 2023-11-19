
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'db.schema.list postgres', ->
  return unless test.tags.db
  return unless test.db.postgresql

  they 'list', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      # Clean
      await @db.database.remove 'db_schema_list_0_db'
      await @db.user.remove 'db_schema_list_0_usr'
      # Prepare
      await @db.user
        username: 'db_schema_list_0_usr'
        password: 'secret'
      await @db.database
        user: 'db_schema_list_0_usr'
        database: 'db_schema_list_0_db'
      # Without a user
      await @db.schema
        database: 'db_schema_list_0_db'
        schema: 'db_schema_list_0_sch_0'
      # With a user
      await @db.schema
        database: 'db_schema_list_0_db'
        schema: 'db_schema_list_0_sch_1'
        owner: 'db_schema_list_0_usr'
      # Test
      {schemas} = await @db.schema.list 'db_schema_list_0_db'
      schemas.should.eql [
        { name: 'db_schema_list_0_sch_0', owner: 'root' }
        { name: 'db_schema_list_0_sch_1', owner: 'db_schema_list_0_usr' }
        { name: 'public', owner: 'pg_database_owner' }
      ]
      # Clean
      await @db.database.remove 'db_schema_list_0_db'
      await @db.user.remove 'db_schema_list_0_usr'
