
mecano = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'

describe 'db.database.wait', ->

  config = test.config()

  they 'is already created (POSTGRES)', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.database.remove 'db_wait_1'
    .db.database
      database: 'db_wait_0'
    .db.database.wait 'db_wait_0', (err, status) ->
      status.should.be.false() unless err
    .db.database.remove 'db_wait_0'
    .then next

  they 'is not yet created (POSTGRES)', (ssh, next) ->
    mecano
      ssh: null
      db: config.db.postgres
    .db.database.remove 'db_wait_1'
    .db.database.wait 'db_wait_1', (err, status) ->
      status.should.be.true() unless err
    .db.database.remove 'db_wait_1'
    .then next
    setTimeout ->
      mecano
        ssh: null
        db: config.db.postgres
      .db.database
        database: 'db_wait_1'
     , 200
