
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
      unless_execute: 'exit 1'
      handler: -> true
      ssh: ssh
    status.should.be.true()

  they 'error if string command with unexpected exit code', ({ssh}) ->
    nikita
      unless_execute: 'exit 2'
      handler: -> true
      ssh: ssh
    .should.be.rejectedWith
      message: [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 2", got 2 instead of 0.'
      ].join ' '
  
  they 'change skip_code value', ({ssh}) ->
    {status} = await nikita
      unless_execute:
        code_skipped: 2
        cmd: 'exit 2'
      handler: -> true
      ssh: ssh
    status.should.be.true()
