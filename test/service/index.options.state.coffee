
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service options state', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service_systemctl

  they 'should start', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      srv_name: config.service.srv_name
      state: 'started'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.true() unless err
    .service # Detect already started
      srv_name: config.service.srv_name
      state: 'started'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should stop', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      srv_name: config.service.srv_name
      state: 'stopped'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service.status
      name: config.service.srv_name
    , (err, {status}) ->
      status.should.be.false() unless err
    .service # Detect already stopped
      srv_name: config.service.srv_name
      state: 'stopped'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should restart', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      srv_name: config.service.srv_name
      state: 'started'
    .service
      srv_name: config.service.srv_name
      state: 'restarted'
    , (err, {status}) ->
      status.should.be.true()
    .service.stop
      name: config.service.srv_name
    .service
      srv_name: config.service.srv_name
      state: 'restarted'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
