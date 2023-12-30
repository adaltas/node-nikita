
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions if_execute', ->
  return unless test.tags.posix

  describe 'exit code', ->

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
      await nikita
        $if_execute:
          code: [, 42]
          command: 'exit 42'
        $handler: -> throw Error 'Oh no!'
        $ssh: ssh

  describe 'array', ->

    it 'run if all command succeed', ->
      nikita.call
        $if_execute: [
          'exit 0'
        ,
          'exit 0'
        ]
        $handler: -> 'Get me!'
      .should.be.finally.eql 'Get me!'

    it 'skip if one command failed', ->
      nikita.call
        $if_execute: [
          'exit 0'
        ,
          'exit 42'
        ,
          'exit 0'
        ]
        $handler: -> throw Error 'Oh no!'

    it 'stop as soon as a command failed', ->
      nikita.call
        $if_execute: [
          'exit 0'
        ,
          'exit 42'
        ,
          code: [, 42]
          command: 'exit 1'
        ]
        $handler: -> throw Error 'Oh no!'
