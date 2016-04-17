
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service start', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service
  
  they 'should start', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      name: 'cronie'
    .service_stop
      name: 'crond'
    .service_start
      name: 'crond'
    , (err, status) ->
      status.should.be.true() unless err
    .service_status
      name: 'crond'
    , (err, started) ->
      started.should.be.true() unless err
    .service_start # Detect already started
      name: 'crond'
    , (err, status) ->
      status.should.be.false() unless err
    .then next
  
  they 'detect invalid service name', (ssh, next) ->
    mecano
      ssh: ssh
    .service_start
      name: 'thisdoenstexit'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid Service Name: thisdoenstexit'
    .then next
  
  they 'store status', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      name: 'cronie'
      srv_name: 'crond'
      action: 'stop'
    .call (options) ->
      (options.store["mecano.service.crond.status"] is undefined).should.be.true()
    .service_start # Detect already started
      name: 'crond'
      cache: true
    .call (options) ->
      options.store["mecano.service.crond.status"].should.eql 'started'
    .then next
