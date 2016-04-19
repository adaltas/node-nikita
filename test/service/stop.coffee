
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service stop', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service

  they 'should stop', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      name: config.service.name
      srv_name: config.service.srv_name
      action: 'start'
    .service_stop
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.true() unless err
    .service_stop
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.false() unless err
    .then next
  
  they 'store status', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      name: config.service.name
    .call (options) ->
      (options.store["mecano.service.crond.status"] is undefined).should.be.true()
    .service_stop # Detect already started
      name: config.service.srv_name
      cache: true
    .call (options) ->
      options.store["mecano.service.crond.status"].should.eql 'stopped'
    .then next
