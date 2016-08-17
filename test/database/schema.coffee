
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'db.schema', ->

  config = test.config()

  they 'add new schema with no owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_0'
    .database.db.add
      database: 'postgres_db_0'
    .database.schema.add
      schema: 'postgres_schema_0'
      database: 'postgres_db_0'
    , (err, status) ->
      status.should.be.true() unless err
    .database.db.remove 'postgres_db_0'
    .then next

  they 'add new schema with not existing owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.db.remove 'postgres_db_1'
    .database.db.add
      database: 'postgres_db_1'
    .database.schema.add
      schema: 'postgres_schema_1'
      database: 'postgres_db_1'
      owner: 'Johny'
      relax: true
    , (err, status) ->
      err.message.should.eql 'Owner Johny does not exists'
    .database.db.remove 'postgres_db_1'
    .then next

  they 'add new schema with existing owner (existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.schema.remove 'postgres_schema_2'
    .database.db.remove 'postgres_db_2'
    .database.user.remove 'postgres_user_2'
    .database.user.add
      username: 'postgres_user_2'
      password: 'postgres_user_2'
    .database.db.add
      database: 'postgres_db_2'
      user: 'postgres_user_2'
    .database.schema.add
      schema: 'postgres_schema_2'
      database: 'postgres_db_2'
      owner: 'postgres_user_2'
    , (err, status) ->
      status.should.be.true() unless err
    .database.schema.remove 'postgres_schema_2'
    .database.db.remove 'postgres_db_2'
    .database.user.remove 'postgres_user_2'
    .then next
  
  they 'add new schema with no owner (not existing db) (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .database.schema.add
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
    .database.schema.remove 'postgres_db_5'
    .database.db.remove 'postgres_db_5'
    .database.user.remove 'mecano_test_5'
    .database.user.add
      username: 'mecano_test_5'
      password: 'test'
      engine: 'postgres'
    .database.db.add
      user: 'mecano_test_5'
      database: 'postgres_db_5'
    .database.schema.add
      database: 'postgres_db_5'
      schema: 'postgres_schema_5'
      owner: 'mecano_test_5'
    , (err, status) ->
      status.should.be.true() unless err
    .database.schema.remove 'postgres_db_5'
    .database.db.remove 'postgres_db_5'
    .database.user.remove 'mecano_test_5'
    .then next
