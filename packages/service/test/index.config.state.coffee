
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service#config.state', ->

  describe 'schema', ->
    return unless test.tags.api

    it 'fail on invalid state', ->
      nikita
      .service
        name: test.service.name
        srv_name: test.service.srv_name
        state: 'invalidstate'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `service`:'
          '#/properties/state/items/enum config/state/0 must be equal to one of the allowed values,'
          'allowedValues is ["started","stopped","restarted"].'
        ].join ' '
    
    it 'requires config `name`, `srv_name` or `chk_name`', ->
      nikita
      .service
        state: 'started'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `service`:'
          '#/dependencies/state/anyOf config must match a schema in anyOf;'
          '#/dependencies/state/anyOf/0/required config must have required property \'name\';'
          '#/dependencies/state/anyOf/1/required config must have required property \'srv_name\';'
          '#/dependencies/state/anyOf/2/required config must have required property \'chk_name\'.'
        ].join ' '
    
    it 'split multiple states', ->
      nikita
      .service
        name: test.service.name
        srv_name: test.service.srv_name
        state: 'started,stopped'
      , ({config}) ->
        config.state
      .should.be.fulfilledWith ['started', 'stopped']

  describe 'action', ->
    return unless test.tags.service_systemctl
    
    @timeout 30000

    they 'should start', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          srv_name: test.service.srv_name
          state: 'started'
        $status.should.be.true()
        {started} = await @service.status
          name: test.service.srv_name
        started.should.be.true()
        {$status} = await @service # Detect already started
          srv_name: test.service.srv_name
          state: 'started'
        $status.should.be.false()

    they 'should stop', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          srv_name: test.service.srv_name
          state: 'stopped'
        $status.should.be.true()
        {started} = await @service.status
          name: test.service.srv_name
        started.should.be.false()
        {$status} = await @service # Detect already stopped
          srv_name: test.service.srv_name
          state: 'stopped'
        $status.should.be.false()

    they 'should restart', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @service.remove
          name: test.service.name
        await @service
          name: test.service.name
          srv_name: test.service.srv_name
          state: 'started'
        {$status} = await @service
          srv_name: test.service.srv_name
          state: 'restarted'
        $status.should.be.true()
        await @service.stop
          name: test.service.srv_name
        {$status} = await @service
          srv_name: test.service.srv_name
          state: 'restarted'
        $status.should.be.false()

    they 'should all together', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          srv_name: test.service.srv_name
          state: 'stopped,started,restarted'
        $status.should.be.true()
        {$status} = await @service
          name: test.service.name
          srv_name: test.service.srv_name
          state: ['stopped', 'started', 'restarted']
        $status.should.be.true()
