
nikita = require '@nikitajs/core/lib'
{tags, config, docker} = require '../test'
they = require('mocha-they')(config)

return unless tags.docker

describe 'docker.tools.execute', ->
  
  describe 'schema', ->

    it 'command is required', ->
      nikita
      .docker.tools.execute()
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /#\/required config must have required property 'command'/

    it 'machine is validated', ->
      nikita
      .docker.tools.execute
        command: 'ok'
        machine: '_'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /#\/definitions\/docker\/properties\/machine\/format config\/machine must match format "hostname"/

    it.skip 'no additionnal properties', ->
      # Not possible with the current implementation
      # additionnalProperties doesn't work with allOf
      nikita
      .docker.tools.execute
        invalid: 'property'
        command: 'ok'
      .should.be.rejectedWith /should NOT have additional properties/
  
  describe 'action', ->

    it 'with a command', ->
      (
        await nikita
          docker: docker
        .docker.tools.execute
          command: 'version'
      )
      .stdout.should.match /\s+Version:\s+\d+\./

    it 'with a global docker option', ->
      (
        await nikita
          docker: docker
        .docker.tools.execute
          command: ''
          opts: version: true
      )
      .stdout.should.match /Docker version \d+/
