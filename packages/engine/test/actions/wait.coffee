
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'action wait', ->

  they 'time as main argument', ({ssh}) ->
    before = Date.now()
    nikita
      ssh: ssh
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
      relax: true
    .should.be.rejectedWith [
      'NIKITA_SCHEMA_VALIDATION_CONFIG:'
      'one error was found in the configuration: #/properties/time/type config.time should be integer.'
    ].join ' '
