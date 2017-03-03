
nikita = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'
each = require 'each'

config = test.config()
return if config.disable_db
for engine, _ of config.db

  describe "db.database.exists #{engine}", ->

    they 'database missing', (ssh, next) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.exists database: 'test_database_exists_0_db', (err, status) ->
        status.should.be.false() unless err
      .db.database.exists 'test_database_exists_0_db', (err, status) ->
        status.should.be.false() unless err
      .assert status: false
      .then next

    they 'database exists', (ssh, next) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'test_database_exists_1_db', shy: true
      .db.database 'test_database_exists_1_db', shy: true
      .db.database.exists database: 'test_database_exists_1_db', (err, status) ->
        status.should.be.true() unless err
      .db.database.exists 'test_database_exists_1_db', (err, status) ->
        status.should.be.true() unless err
      .db.database.remove 'test_database_exists_1_db', shy: true
      .assert status: false
      .then next
