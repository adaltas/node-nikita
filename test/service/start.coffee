
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.start', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service_systemctl
  
  they 'should start', (ssh) ->
    nikita
      ssh: ssh
    .service
      name: config.service.name
    .service.stop
      name: config.service.srv_name
    .service.start
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: config.service.srv_name
    , (err, {status}) ->
      started.should.be.true() unless err
    .service.start # Detect already started
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'no error when invalid service name', (ssh) ->
    nikita
      ssh: ssh
    .service.start
      name: 'thisdoenstexit'
    , (err, {status}) ->
      (!!err).should.be.false()
      status.should.be.false()
    .promise()
