
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.execute.assert', ->

  scratch = test.scratch @

  they 'assert stdout match content', (ssh, next) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: 'text=hello; echo $text'
      content: 'hello\n'
    .system.execute.assert
      cmd: 'text=hello; echo $text'
      content: 'hello'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid content'
    .then next

  they 'assert stdout match regexp', (ssh, next) ->
    nikita
      ssh: ssh
    .system.execute.assert
      cmd: "echo \"toto\nest\r\nau\rbistrot\""
      content: /^bistrot$/m
    .system.execute.assert
      cmd: "echo \"toto\nest\r\nau\rbistrot\""
      content: /^ohno$/m
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid content match'
    .then next
