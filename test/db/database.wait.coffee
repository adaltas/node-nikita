
nikita = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'

config = test.config()
return if config.disable_db
for engine, _ of config.db

  describe "db.database.wait #{engine}", ->

    they 'is already created', (ssh, next) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'db_wait_1'
      .db.database 'db_wait_0'
      .db.database.wait 'db_wait_0', (err, status) ->
        status.should.be.false() unless err
      .db.database.remove 'db_wait_0'
      .then next

    they 'is not yet created', (ssh, next) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'db_wait_1'
      .db.database.wait 'db_wait_1', (err, status) ->
        status.should.be.true() unless err
      .db.database.remove 'db_wait_1'
      .then next
      setTimeout ->
        nikita
          ssh: ssh
          db: config.db[engine]
        .db.database 'db_wait_1'
       , 200
