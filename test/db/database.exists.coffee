
nikita = require '../../src'
{tags, ssh, db} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.db

for engine, _ of db

  describe "db.database.exists #{engine}", ->

    they 'database missing', (ssh) ->
      nikita
        ssh: ssh
        db: db[engine]
      .db.database.exists database: 'test_database_exists_0_db', (err, {status}) ->
        status.should.be.false() unless err
      .db.database.exists 'test_database_exists_0_db', (err, {status}) ->
        status.should.be.false() unless err
      .assert status: false
      .promise()

    they 'database exists', (ssh) ->
      nikita
        ssh: ssh
        db: db[engine]
      .db.database.remove 'test_database_exists_1_db', shy: true
      .db.database 'test_database_exists_1_db', shy: true
      .db.database.exists database: 'test_database_exists_1_db', (err, {status}) ->
        status.should.be.true() unless err
      .db.database.exists 'test_database_exists_1_db', (err, {status}) ->
        status.should.be.true() unless err
      .db.database.remove 'test_database_exists_1_db', shy: true
      .assert status: false
      .promise()
