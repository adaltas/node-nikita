
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
    .service.install config.service.name
    .service.start config.service.srv_name
    .service.stop
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.true() unless err
    .service.stop
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'name as default argument', (ssh, next) ->
    mecano
      ssh: ssh
    .service.install config.service.name
    .service.start config.service.srv_name
    .service.stop config.service.srv_name, (err, status) ->
      status.should.be.true() unless err
    .then next
  
  they 'store status', (ssh, next) ->
    mecano
      ssh: ssh
    .service.install config.service.name
    .call (options) ->
      (options.store["mecano.service.crond.status"] is undefined).should.be.true()
    .service.stop # Detect already started
      name: config.service.srv_name
      cache: true
    .call (options) ->
      options.store["mecano.service.crond.status"].should.eql 'stopped'
    .then next
