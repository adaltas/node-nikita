
they = require 'ssh2-they'
nikita = require '../../src'
conditions = require '../../src/misc/conditions'
{tags} = require '../test'

return unless tags.posix

describe 'if_exec', ->

  they 'string succeed if command succeed', (ssh, next) ->
    conditions.if_exec.call nikita(ssh: ssh),
      options:
        if_exec: "exit 0"
      -> next()
      (err) -> false.should.be.true()

  they 'string fail if command succeed', (ssh, next) ->
    conditions.if_exec.call nikita(ssh: ssh),
      options:
        if_exec: "exit 1"
      -> false.should.be.true()
      () -> next()

  they 'array fail if at least one command fail', (ssh, next) ->
    conditions.if_exec.call nikita(ssh: ssh),
      options:
        if_exec: [
          "exit 0"
          "exit 1"
          "exit 0"
        ]
      -> false.should.be.true()
      next

  they 'array succeed if all commands succeed', (ssh, next) ->
    conditions.if_exec.call nikita(ssh: ssh),
      options:
        if_exec: [
          "exit 0"
          "exit 0"
          "exit 0"
        ]
      -> next()
      (err) -> false.should.be.true()

  they 'dont change status of previous action', (ssh) ->
    nikita
      ssh: ssh
    .call ({}, callback) ->
      callback null, true
    .call
      unless_exec: 'exit 1'
    , ({}, callback) ->
      callback null, true
    .call
      if: ->
        @status(-1).should.be.true()
        @status(-2).should.be.true()
        (@status(-3) is undefined).should.be.true()
        true
    , ->
      @status(-1).should.be.true()
      @status(-2).should.be.true()
      (@status(-3) is undefined).should.be.true()
    .promise()

describe 'unless_exec', ->

  they 'string succeed if command fail', (ssh, next) ->
    conditions.unless_exec.call nikita(ssh: ssh),
      options:
        unless_exec: "exit 0"
      -> false.should.be.true()
      next

  they 'string fail if command fail', (ssh, next) ->
    conditions.unless_exec.call nikita(ssh: ssh),
      options:
        unless_exec: "exit 1"
      -> next()
      () -> false.should.be.true()

  they 'array fail if at least one command succeed', (ssh, next) ->
    conditions.unless_exec.call nikita(ssh: ssh),
      options:
        unless_exec: [
          "exit 1"
          "exit 0"
          "exit 1"
        ]
      -> false.should.be.true()
      next

  they 'array succeed if all commands fail', (ssh, next) ->
    conditions.unless_exec.call nikita(ssh: ssh),
      options:
        unless_exec: [
          "exit 1"
          "exit 1"
          "exit 1"
        ]
      -> next()
      (err) -> false.should.be.true()
