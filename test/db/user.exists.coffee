
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'db.user.exists', ->

  config = test.config()

  they 'with status as false', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.user.remove 'test_2', shy: true
    .db.user.exists
      name: 'test_3'
    , (err, status) ->
      status.should.be.false() unless err
    .then (err, status) ->
      # Modules of type exists shall be shy
      status.should.be.false() unless err
      next err

  they 'with status as false as true', (ssh, next) ->
    mecano
      ssh: ssh
      db: config.db.postgres
    .db.user.remove 'test_2', shy: true
    .db.user
      username: 'test_4'
      password: 'test_4'
    .db.user.exists
      name: 'test_4'
    , (err, status) ->
      status.should.be.true() unless err
    .then (err, status) ->
      # Modules of type exists shall be shy
      status.should.be.false() unless err
      next err
