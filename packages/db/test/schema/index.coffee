
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'db.schema postgres', ->
  return unless test.tags.db
  return unless test.db.postgresql

  they 'status on new schema with no owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'postgres_db_0'
      await @db.database 'postgres_db_0'
      {$status} = await @db.schema
        schema: 'postgres_schema_0'
        database: 'postgres_db_0'
      $status.should.be.true()
      {$status} = await @db.schema
        schema: 'postgres_schema_0'
        database: 'postgres_db_0'
      $status.should.be.false()
      await @db.database.remove 'postgres_db_0'

  they 'add new schema with not existing owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      try
        await @db.database.remove 'postgres_db_1'
        await @db.database 'postgres_db_1'
        await @db.schema
          schema: 'postgres_schema_1'
          database: 'postgres_db_1'
          owner: 'Johny'
        throw Error 'Oh no'
      catch err
        err.message.should.eql 'Owner Johny does not exists'
      finally
        await @db.database.remove 'postgres_db_1'

  they 'add new schema with existing owner (existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'postgres_db_2'
      await @db.user.remove 'postgres_user_2'
      await @db.user
        username: 'postgres_user_2'
        password: 'postgres_user_2'
      await @db.database
        database: 'postgres_db_2'
        user: 'postgres_user_2'
      {$status} = await @db.schema
        schema: 'postgres_schema_2'
        database: 'postgres_db_2'
        owner: 'postgres_user_2'
      $status.should.be.true()
      await @db.database.remove 'postgres_db_2'
      await @db.user.remove 'postgres_user_2'
    
  they 'add new schema with no owner (not existing db)', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      @db.schema
        schema: 'postgres_schema_4'
        database: 'postgres_db_4'
      .should.be.rejectedWith
        message: 'Database does not exist postgres_db_4'
  
  they 'add new schema after adding database and user', ({ssh}) ->
    nikita
      $ssh: ssh
      db: test.db.postgresql
    , ->
      await @db.database.remove 'postgres_db_5'
      await @db.user.remove 'nikita_test_5'
      await @db.user
        username: 'nikita_test_5'
        password: 'secret'
        engine: 'postgresql'
      await @db.database
        user: 'nikita_test_5'
        database: 'postgres_db_5'
      {$status} = await @db.schema
        database: 'postgres_db_5'
        schema: 'postgres_schema_5'
        owner: 'nikita_test_5'
      $status.should.be.true()
      await @db.database.remove 'postgres_db_5'
      await @db.user.remove 'nikita_test_5'
