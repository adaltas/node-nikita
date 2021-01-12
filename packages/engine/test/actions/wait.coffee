
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.wait', ->

  they 'time as main argument', ({ssh}) ->
    before = 0
    nikita
      ssh: ssh
    .call ->
      before = Date.now()
    .wait 500
    .wait '500'
    .wait 0
    .call ->
      interval = Date.now() - before
      (interval >= 1000 and interval < 1500).should.be.true()

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
