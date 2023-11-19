
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions if_execute', ->
  return unless test.tags.posix

  they 'pass if string command is successfull', ({ssh}) ->
    {$status} = await nikita
      $if_execute: 'exit 0'
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'skip if string command exit error exit code`', ({ssh}) ->
    {$status} = await nikita
      $if_execute: 'exit 42'
      $handler: -> true
      $ssh: ssh
    $status.should.be.false()

  they 'error if `code.false` not match', ({ssh}) ->
    nikita
      $if_execute:
        code: [, 1]
        command: 'exit 42'
      $handler: -> true
      $ssh: ssh
    .should.be.rejectedWith
      message: [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42", got 42 instead of {"true":[],"false":[1]}.'
      ].join ' '
  
  they 'skip if `code.false` match', ({ssh}) ->
    {$status} = await nikita
      $if_execute:
        code: [, 42]
        command: 'exit 42'
      $handler: -> true
      $ssh: ssh
    $status.should.be.false()
