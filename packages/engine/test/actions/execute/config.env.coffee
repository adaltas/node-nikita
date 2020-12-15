
stream = require 'stream'
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.execute.config.env', ->

  they 'invalid schema', ({ssh}) ->
    nikita ssh: ssh, ->
      @execute
        command: 'whoami'
        env: ['oh no']
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration of action `execute`:'
          '#/properties/env/type config.env should be object,'
          'type is "object".'
        ].join ' '

  they 'pass variables', ({ssh}) ->
    # accepted environment variables 
    # is determined by the AcceptEnv server setting
    # default values are "LANG,LC_*"
    nikita ssh: ssh, ->
      {stdout} = await @execute
        command: 'env'
        env: 'LANG': 'tv'
      stdout.split('\n').includes('LANG=tv').should.be.true()
