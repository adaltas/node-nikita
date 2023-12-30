
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions unless_execute', ->
  return unless test.tags.posix

  describe 'exit code', ->

    they 'skip if string command is successfull', ({ssh}) ->
      await nikita
        $unless_execute: 'exit 0'
        $disabled: true
        $handler: -> throw Error 'Oh no!'
        $ssh: ssh

    they 'pass if string command exit error exit code', ({ssh}) ->
      {$status} = await nikita
        $unless_execute: 'exit 42'
        $handler: -> true
        $ssh: ssh
      $status.should.be.true()

    they 'error if `code.false` not match', ({ssh}) ->
      nikita
        $unless_execute:
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
    
    they 'pass if `code.false` match', ({ssh}) ->
      {$status} = await nikita
        $unless_execute:
          code: [, 42]
          command: 'exit 42'
        $handler: -> true
        $ssh: ssh
      $status.should.be.true()
  
  describe 'array', ->

    it 'skip if all command succeed', ->
      nikita .call
        $unless_execute: [
          'exit 0'
        ,
          'exit 0'
        ]
        $handler: -> throw Error 'Oh no!'

    it 'skip if at least one command succeed', ->
      nikita.call
        $unless_execute: [
          'exit 0'
        ,
          'exit 42'
        ]
        $handler: -> throw Error 'Oh no!'

    it 'run if all command failed', ->
      nikita.call
        $unless_execute: [
          'exit 42'
        ,
          'exit 42'
        ]
        $handler: -> 'called'
      .should.be.finally.eql 'called'
  
    it 'stop as soon as a command succeed', ->
      nikita .call
        $unless_execute: [
          'exit 0'
        ,
          command: 'exit 1'
        ]
        $handler: -> throw Error 'Oh no!'
