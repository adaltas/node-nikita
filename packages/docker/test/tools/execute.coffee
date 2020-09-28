
nikita = require '@nikitajs/engine/src'
{tags, ssh, docker} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.docker

describe 'docker.tools.execute', ->
  
  describe 'schema', ->

    it 'valid', ->
      nikita
      .docker.tools.execute
        cmd: 'ok'
        dry: true

    it 'cmd is required', ->
      nikita
      .docker.tools.execute()
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `docker.tools.execute`:'
        '#/required config should have required property \'cmd\'.'
      ].join ' '

    it 'machine is validated', ->
      nikita
      .docker.tools.execute
        cmd: 'ok'
        machine: 111
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `docker.tools.execute`:'
        '#/properties/machine/type config.machine should be string, type is "string".'
      ].join ' '

    it 'no additionnal properties', ->
      nikita
      .docker.tools.execute
        invalid: 'property'
        cmd: 'ok'
      .should.be.rejectedWith /should NOT have additional properties/
