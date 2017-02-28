
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
      name: config.service.name
    .service.stop
      name: config.service.srv_name
    .service.start
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.true() unless err
    .service.status
      name: config.service.srv_name
    , (err, started) ->
      started.should.be.true() unless err
    .service.start # Detect already started
      name: config.service.srv_name
    , (err, status) ->
      status.should.be.false() unless err
    .then next
  
  # they 'detect invalid service name', (ssh, next) ->
  #   mecano
  #     ssh: ssh
  #   .service.start
  #     name: 'thisdoenstexit'
  #     relax: true
  #   , (err) ->
  #     err.message.should.eql 'Invalid Service Name: thisdoenstexit'
  #   .then next
  they 'no error when invalid service name', (ssh, next) ->
    mecano
      ssh: ssh
    .service.start
      name: 'thisdoenstexit'
      relax: true
    , (err, status) ->
      status.should.be.false()
    .then next
  
  they 'store status', (ssh, next) ->
    mecano
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service
      name: 'cronie'
      srv_name: config.service.srv_name
      action: 'stop'
    .call (options) ->
      (options.store["mecano.service.#{config.service.srv_name}.status"] is undefined).should.be.true()
    .service.start # Detect already started
      name: config.service.srv_name
      cache: true
    .call (options) ->
      options.store["mecano.service.#{config.service.srv_name}.status"].should.eql 'started'
    .then next
