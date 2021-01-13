
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.wait', ->

  they 'time as main argument', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {before} = await @call ->
        before: Date.now()
      await @wait 200
      await @wait '200'
      await @wait 0
      interval = Date.now() - before
      (interval >= 400 and interval < 600).should.be.true()

  they 'validate argument', ({ssh}) ->
    before = Date.now()
    nikita
      ssh: ssh
    .wait
      time: 'an': 'object'
    .should.be.rejectedWith [
      'NIKITA_SCHEMA_VALIDATION_CONFIG:'
      'one error was found in the configuration of action `wait`:'
      '#/properties/time/type config.time should be integer,'
      'type is "integer".'
    ].join ' '
