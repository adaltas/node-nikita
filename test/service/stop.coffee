
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.stop', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service

  they 'should stop', (ssh, next) ->
    nikita
      ssh: ssh
    .service.install config.service.name
    .service.start config.service.srv_name
    .service.stop config.service.srv_name, (err, status) ->
      status.should.be.true() unless err
    .service.stop config.service.srv_name, (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'no error when invalid service name', (ssh, next) ->
    nikita
      ssh: ssh
    .service.stop
      name: 'thisdoenstexit'
      relax: true
    , (err, status) ->
      status.should.be.false()
    .then next
