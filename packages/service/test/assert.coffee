
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service.assert', ->

  describe 'installed.service', ->
    
    return unless test.tags.service_install

    they 'succeed if package is installed', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
        await @service.assert
          name: test.service.name
          installed: true

    they 'fail if package isnt installed', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service.assert
          name: test.service.name
          installed: true
        .should.be.rejectedWith
          code: 'NIKITA_SERVICE_ASSERT_NOT_INSTALLED'
          message: [
            'NIKITA_SERVICE_ASSERT_NOT_INSTALLED:'
            "service \"#{test.service.name}\" is not installed."
          ].join(' ')

  describe 'started.systemctl', ->
  
    @timeout 50000
    return unless test.tags.service_systemctl

    they 'succeed if service is started', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
        await @service.start
          name: test.service.srv_name
        await @service.assert
          name: test.service.srv_name
          started: true
        await @service.assert
          name: test.service.srv_name
          started: false
        .should.be.rejectedWith
          message: "Service Started: #{test.service.srv_name}"

    they 'fail if service isnt started', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
        await @service.stop
          name: test.service.srv_name
        await @service.assert
          name: test.service.srv_name
          started: false
        await @service.assert
          name: test.service.srv_name
          started: true
        .should.be.rejectedWith
          message: "Service Not Started: #{test.service.srv_name}"

  describe 'stopped.systemctl', ->
    
    @timeout 50000
    return unless test.tags.service_systemctl

    they 'succeed if service is started', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
        await @service.stop
          name: test.service.srv_name
        await @service.assert
          name: test.service.srv_name
          stopped: true
        await @service.assert
          name: test.service.srv_name
          stopped: false
        .should.be.rejectedWith
          message: "Service Stopped: #{test.service.srv_name}"

    they 'fail if service isnt started', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
        await @service.start
          name: test.service.srv_name
        await @service.assert
          name: test.service.srv_name
          stopped: false
        await @service.assert
          name: test.service.srv_name
          stopped: true
        .should.be.rejectedWith
          message: "Service Not Stopped: #{test.service.srv_name}"
