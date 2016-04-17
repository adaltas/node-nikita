
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service startup', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service
  
  they 'declare on startup with boolean', (ssh, next) ->
    mecano
      ssh: ssh
    .service_remove
      name: 'cronie'
    .service
      name: 'cronie'
      srv_name: 'crond'
      startup: true
    , (err, status) ->
      status.should.be.true() unless err
    .service
      name: 'cronie'
      srv_name: 'crond'
      startup: true
    , (err, status) ->
      status.should.be.false() unless err
    .service
      name: 'cronie'
      srv_name: 'crond'
      startup: false
    , (err, status) ->
      status.should.be.true() unless err
    .service
      name: 'cronie'
      srv_name: 'crond'
      startup: false
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'notice a change in startup level', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      # name: 'cronie'
      srv_name: 'crond'
      startup: '235'
    , (err, status) ->
      status.should.be.true() unless err
    .service
      # name: 'cronie'
      srv_name: 'crond'
      startup: '2345'
    , (err, status) ->
      status.should.be.true() unless err
    .service
      # name: 'cronie'
      srv_name: 'crond'
      startup: '2345'
    , (err, status) ->
      status.should.be.false() unless err
    .then next
