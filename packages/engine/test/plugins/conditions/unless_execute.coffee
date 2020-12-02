
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'plugin.condition unless_execute', ->

  they 'skip if string command is successfull', ({ssh}) ->
    {status, value} = await nikita
      unless_execute: 'exit 0'
      disabled: true
      handler: -> throw Error 'forbidden'
      ssh: ssh
    status.should.be.false()

  they 'pass if string command exit with code_skipped', ({ssh}) ->
    {status} = await nikita
      unless_execute: 'exit 42'
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'error if code_skipped not match', ({ssh}) ->
    nikita
      unless_execute:
        code_skipped: 1
        command: 'exit 42'
      handler: -> true
      ssh: ssh
    .should.be.rejectedWith
      message: [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42", got 42 instead of 0.'
      ].join ' '
  
  they 'pass if skip_code match', ({ssh}) ->
    {status} = await nikita
      unless_execute:
        code_skipped: 42
        command: 'exit 42'
      handler: -> true
      ssh: ssh
    status.should.be.true()
