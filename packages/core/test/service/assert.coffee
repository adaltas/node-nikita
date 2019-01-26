
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure(ssh)

describe 'service.assert installed', ->
  
  @timeout 50000
  return unless tags.service_install

  they 'succeed if package is installed', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service.assert
      name: service.name
      installed: true
    .promise()

  they 'fail if package isnt installed', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service.assert
      name: service.name
      installed: true
      relax: true
    , (err) ->
      err.message.should.eql "Uninstalled Package: #{service.name}"
    .promise()

describe 'service.assert started', ->
  
  @timeout 50000
  return unless tags.service_systemctl

  they 'succeed if service is started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service.start
      name: service.srv_name
    .service.assert
      name: service.srv_name
      started: true
    .service.assert
      name: service.srv_name
      started: false
      relax: true
    , (err) ->
      err.message.should.eql "Service Started: #{service.srv_name}"
    .promise()

  they 'fail if service isnt started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service.stop
      name: service.srv_name
    .service.assert
      name: service.srv_name
      started: true
      relax: true
    , (err) ->
      err.message.should.eql "Service Not Started: #{service.srv_name}"
    .service.assert
      name: service.srv_name
      started: false
    .promise()

describe 'service.assert stopped', ->
  
  @timeout 50000
  return unless tags.service_systemctl

  they 'succeed if service is started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service.stop
      name: service.srv_name
    .service.assert
      name: service.srv_name
      stopped: true
    .service.assert
      name: service.srv_name
      stopped: false
      relax: true
    , (err) ->
      err.message.should.eql "Service Stopped: #{service.srv_name}"
    .promise()

  they 'fail if service isnt started', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service.start
      name: service.srv_name
    .service.assert
      name: service.srv_name
      stopped: true
      relax: true
    , (err) ->
      err.message.should.eql "Service Not Stopped: #{service.srv_name}"
    .service.assert
      name: service.srv_name
      stopped: false
    .promise()
