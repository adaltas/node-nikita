
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'db.schema postgres', ->

  config = test.config()

  they 'add new schema with no owner (existing db)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.database.remove 'postgres_db_0'
    .db.database
      database: 'postgres_db_0'
    .db.schema
      schema: 'postgres_schema_0'
      database: 'postgres_db_0'
    , (err, status) ->
      status.should.be.true() unless err
    .db.database.remove 'postgres_db_0'
    .then next

  they 'add new schema with not existing owner (existing db)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.database.remove 'postgres_db_1'
    .db.database
      database: 'postgres_db_1'
    .db.schema
      schema: 'postgres_schema_1'
      database: 'postgres_db_1'
      owner: 'Johny'
      relax: true
    , (err, status) ->
      err.message.should.eql 'Owner Johny does not exists'
    .db.database.remove 'postgres_db_1'
    .then next

  they 'add new schema with existing owner (existing db)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
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
    , (err, status) ->
      status.should.be.true() unless err
    .db.schema.remove 'postgres_schema_2'
    .db.database.remove 'postgres_db_2'
    .db.user.remove 'postgres_user_2'
    .then next
  
  they 'add new schema with no owner (not existing db)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.schema
      schema: 'postgres_schema_4'
      database: 'postgres_db_4'
      relax: true
    , (err, status) ->
      err.message.should.eql 'Database does not exist postgres_db_4'
      status.should.be.false()
    .then next
  
  they 'add new schema after adding database and user', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.schema.remove 'postgres_db_5'
    .db.database.remove 'postgres_db_5'
    .db.user.remove 'mecano_test_5'
    .db.user
      username: 'mecano_test_5'
      password: 'test'
      engine: 'postgres'
    .db.database
      user: 'mecano_test_5'
      database: 'postgres_db_5'
    .db.schema
      database: 'postgres_db_5'
      schema: 'postgres_schema_5'
      owner: 'mecano_test_5'
    , (err, status) ->
      status.should.be.true() unless err
    .db.schema.remove 'postgres_db_5'
    .db.database.remove 'postgres_db_5'
    .db.user.remove 'mecano_test_5'
    .then next
