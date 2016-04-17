
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service restart', ->
  
  @timeout 20000
  config = test.config()
  return if config.disable_service

  they 'should restart', (ssh, next) ->
    mecano
      ssh: ssh
    .service
      name: 'cronie'
    .service_start
      name: 'crond'
    .service_restart
      name: 'crond'
    , (err, restarted) ->
      restarted.should.be.true()
    .then next
