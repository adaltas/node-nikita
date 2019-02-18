
nikita = require '@nikitajs/core'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

describe 'db.schema postgres', ->

  return unless db.postgresql

  they 'add new schema with no owner (existing db)', ({ssh}) ->
    nikita
      ssh: ssh
      db: db.postgresql
    .db.database.remove 'postgres_db_0'
    .db.database 'postgres_db_0'
    .db.schema
      schema: 'postgres_schema_0'
      database: 'postgres_db_0'
    , (err, {status}) ->
      status.should.be.true() unless err
    .db.database.remove 'postgres_db_0'
    .promise()

  they 'add new schema with not existing owner (existing db)', ({ssh}) ->
    nikita
      ssh: ssh
      db: db.postgresql
    .db.database.remove 'postgres_db_1'
    .db.database 'postgres_db_1'
    .db.schema
      schema: 'postgres_schema_1'
      database: 'postgres_db_1'
      owner: 'Johny'
      relax: true
    , (err) ->
      err.message.should.eql 'Owner Johny does not exists'
    .db.database.remove 'postgres_db_1'
    .promise()

  they 'add new schema with existing owner (existing db)', ({ssh}) ->
    nikita
      ssh: ssh
      db: db.postgresql
    .db.schema.remove 'postgres_schema_2'
    .db.database.remove 'postgres_db_2'
    .db.user.remove 'postgres_user_2'
    .db.user
      username: 'postgres_user_2'
      password: 'postgres_user_2'
    .db.database
      database: 'postgres_db_2'
      user: 'postgres_user_2'
    .db.schema
      schema: 'postgres_schema_2'
      database: 'postgres_db_2'
      owner: 'postgres_user_2'
    , (err, {status}) ->
      status.should.be.true() unless err
    .db.schema.remove 'postgres_schema_2'
    .db.database.remove 'postgres_db_2'
    .db.user.remove 'postgres_user_2'
    .promise()
  
  they 'add new schema with no owner (not existing db)', ({ssh}) ->
    nikita
      ssh: ssh
      db: db.postgresql
    .db.schema
      schema: 'postgres_schema_4'
      database: 'postgres_db_4'
      relax: true
    , (err) ->
      err.message.should.eql 'Database does not exist postgres_db_4'
    .promise()
  
  they 'add new schema after adding database and user', ({ssh}) ->
    nikita
      ssh: ssh
      db: db.postgresql
    .db.schema.remove 'postgres_db_5'
    .db.database.remove 'postgres_db_5'
    .db.user.remove 'nikita_test_5'
    .db.user
      username: 'nikita_test_5'
      password: 'test'
      engine: 'postgresql'
    .db.database
      user: 'nikita_test_5'
      database: 'postgres_db_5'
    .db.schema
      database: 'postgres_db_5'
      schema: 'postgres_schema_5'
      owner: 'nikita_test_5'
    , (err, {status}) ->
      status.should.be.true() unless err
    .db.schema.remove 'postgres_db_5'
    .db.database.remove 'postgres_db_5'
    .db.user.remove 'nikita_test_5'
    .promise()
