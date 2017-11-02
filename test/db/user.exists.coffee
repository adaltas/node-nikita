
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

config = test.config()
return if config.disable_db
for engine, _ of config.db

  describe "db.user.exists #{engine}", ->

    they 'with status as false', (ssh) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.user.remove 'test_user_exists_1_user', shy: true
      .db.user.exists
        username: 'test_user_exists_1_user'
      , (err, status) ->
        status.should.be.false() unless err
      .then (err, status) ->
        throw err if err
        # Modules of type exists shall be shy
        status.should.be.false()
      .promise()

    they 'with status as false as true', (ssh) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.user.remove 'test_user_exists_2_user', shy: true
      .db.user
        username: 'test_user_exists_2_user'
        password: 'test_user_exists_2_password'
        shy: true
      .db.user.exists
        username: 'test_user_exists_2_user'
      , (err, status) ->
        status.should.be.true() unless err
      .db.user.remove 'test_user_exists_2_user', shy: true
      .call ->
        # Modules of type exists shall be shy
        @status().should.be.false()
      .promise()
