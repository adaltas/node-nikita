
nikita = require '@nikitajs/engine/lib'
{tags, ssh, service} = require './test'
they = require('ssh2-they').configure ssh

describe 'service.assert', ->

  describe 'installed', ->
    
    @timeout 50000
    return unless tags.service_install

    they 'succeed if package is installed', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
        @service.assert
          name: service.name
          installed: true

    they 'fail if package isnt installed', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service.assert
          name: service.name
          installed: true
        .should.be.rejectedWith
          message: "Uninstalled Package: #{service.name}"

  describe 'started', ->
  
    @timeout 50000
    return unless tags.service_systemctl

    they 'succeed if service is started', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
        @service.start
          name: service.srv_name
        @service.assert
          name: service.srv_name
          started: true
        @service.assert
          name: service.srv_name
          started: false
        .should.be.rejectedWith
          message: "Service Started: #{service.srv_name}"

    they 'fail if service isnt started', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
        @service.stop
          name: service.srv_name
        @service.assert
          name: service.srv_name
          started: true
        .should.be.rejectedWith
          message: "Service Not Started: #{service.srv_name}"
        @service.assert
          name: service.srv_name
          started: false

  describe 'stopped', ->
    
    @timeout 50000
    return unless tags.service_systemctl

    they 'succeed if service is started', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
        @service.stop
          name: service.srv_name
        @service.assert
          name: service.srv_name
          stopped: true
        @service.assert
          name: service.srv_name
          stopped: false
        .should.be.rejectedWith
          message: "Service Stopped: #{service.srv_name}"

    they 'fail if service isnt started', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
        @service.start
          name: service.srv_name
        @service.assert
          name: service.srv_name
          stopped: true
        .should.be.rejectedWith
          message: "Service Not Stopped: #{service.srv_name}"
        @service.assert
          name: service.srv_name
          stopped: false
