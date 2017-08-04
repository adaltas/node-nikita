
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service.assert installed', ->
  
  @timeout 50000
  config = test.config()
  return if config.disable_service_install

  they 'succeed if package is installed', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service.assert
      name: config.service.name
      installed: true
    .promise()

  they 'fail if package isnt installed', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service.assert
      name: config.service.name
      installed: true
      relax: true
    , (err) ->
      err.message.should.eql "Uninstalled Package: #{config.service.name}"
    .promise()

describe 'service.assert started', ->
  
  @timeout 50000
  config = test.config()
  return if config.disable_service_systemctl

  they 'succeed if service is started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service.start
      name: config.service.srv_name
    .service.assert
      name: config.service.srv_name
      started: true
    .service.assert
      name: config.service.srv_name
      started: false
      relax: true
    , (err) ->
      err.message.should.eql "Service Started: #{config.service.srv_name}"
    .promise()

  they 'fail if service isnt started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service.stop
      name: config.service.srv_name
    .service.assert
      name: config.service.srv_name
      started: true
      relax: true
    , (err) ->
      err.message.should.eql "Service Not Started: #{config.service.srv_name}"
    .service.assert
      name: config.service.srv_name
      started: false
    .promise()

describe 'service.assert stopped', ->
  
  @timeout 50000
  config = test.config()
  return if config.disable_service_systemctl

  they 'succeed if service is started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service.stop
      name: config.service.srv_name
    .service.assert
      name: config.service.srv_name
      stopped: true
    .service.assert
      name: config.service.srv_name
      stopped: false
      relax: true
    , (err) ->
      err.message.should.eql "Service Stopped: #{config.service.srv_name}"
    .promise()

  they 'fail if service isnt started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
    .service.start
      name: config.service.srv_name
    .service.assert
      name: config.service.srv_name
      stopped: true
      relax: true
    , (err) ->
      err.message.should.eql "Service Not Stopped: #{config.service.srv_name}"
    .service.assert
      name: config.service.srv_name
      stopped: false
    .promise()
