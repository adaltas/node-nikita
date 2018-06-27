
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.restart', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service_systemctl

  they 'should restart', (ssh) ->
    nikita
      ssh: ssh
    .service
      name: config.service.name
    .service.start
      name: config.service.srv_name
    .service.restart
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.true()
    .promise()
