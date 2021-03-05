
nikita = require '@nikitajs/core/lib'
{tags, config, service} = require './test'
they = require('mocha-they')(config)

return unless tags.service_systemctl

describe 'service#config.state', ->

  describe 'schema', ->

    it 'fail on invalid state', ->
      nikita
      .service
        name: service.name
        srv_name: service.srv_name
        state: 'invalidstate'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `service`:'
          '#/properties/state/items/enum config/state/0 should be equal to one of the allowed values,'
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
          'multiple errors where found in the configuration of action `service`:'
          '#/dependencies/state/anyOf config should match some schema in anyOf;'
          '#/dependencies/state/anyOf/0/required config should have required property \'name\';'
          '#/dependencies/state/anyOf/1/required config should have required property \'srv_name\';'
          '#/dependencies/state/anyOf/2/required config should have required property \'chk_name\'.'
        ].join ' '

  describe 'action', ->
    
    @timeout 30000

    they 'should start', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        {$status} = await @service
          name: service.name
          srv_name: service.srv_name
          state: 'started'
        $status.should.be.true()
        {$status} = await @service.status
          name: service.srv_name
        $status.should.be.true()
        {$status} = await @service # Detect already started
          srv_name: service.srv_name
          state: 'started'
        $status.should.be.false()

    they 'should stop', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        {$status} = await @service
          name: service.name
          srv_name: service.srv_name
          state: 'stopped'
        $status.should.be.true()
        {$status} = await @service.status
          name: service.srv_name
        $status.should.be.false()
        {$status} = await @service # Detect already stopped
          srv_name: service.srv_name
          state: 'stopped'
        $status.should.be.false()

    they 'should restart', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        @service
          name: service.name
          srv_name: service.srv_name
          state: 'started'
        {$status} = await @service
          srv_name: service.srv_name
          state: 'restarted'
        $status.should.be.true()
        @service.stop
          name: service.srv_name
        {$status} = await @service
          srv_name: service.srv_name
          state: 'restarted'
        $status.should.be.false()

    they 'should all together', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @service.remove
          name: service.name
        {$status} = await @service
          name: service.name
          srv_name: service.srv_name
          state: 'stopped,started,restarted'
        $status.should.be.true()
        {$status} = await @service
          name: service.name
          srv_name: service.srv_name
          state: ['stopped', 'started', 'restarted']
        $status.should.be.true()
