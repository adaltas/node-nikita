
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.status', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service_systemctl
  
  they 'store status', (ssh) ->
    nikita
      ssh: ssh
    .service
      name: config.service.name
    .service.stop
      name: config.service.srv_name
    .service.status
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .service.start
      name: config.service.srv_name
    .service.status
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.stop
      name: config.service.srv_name
    .service.status
      name: config.service.name
      srv_name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
