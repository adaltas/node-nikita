
they = require 'ssh2-they'
nikita = require '../../src'
conditions = require '../../src/misc/conditions'

describe 'if_exec', ->

  they 'should succeed if command succeed', (ssh, next) ->
    conditions.if_exec.call nikita(),
      ssh: ssh
      if_exec: "exit 0"
      -> next()
      (err) -> false.should.be.true()

  they 'should fail if command succeed', (ssh, next) ->
    conditions.if_exec.call nikita(),
      ssh: ssh
      if_exec: "exit 1"
      -> false.should.be.true()
      () -> next()

  they 'should fail if at least one command fail', (ssh, next) ->
    conditions.if_exec.call nikita(),
      ssh: ssh
      if_exec: [
        "exit 0"
        "exit 1"
        "exit 0"
      ]
      -> false.should.be.true()
      next

  they 'should succeed if all commands succeed', (ssh, next) ->
    conditions.if_exec.call nikita(),
      ssh: ssh
      if_exec: [
        "exit 0"
        "exit 0"
        "exit 0"
      ]
      -> next()
      (err) -> false.should.be.true()

describe 'unless_exec', ->

  they 'should succeed if command fail', (ssh, next) ->
    conditions.unless_exec.call nikita(),
      ssh: ssh
      unless_exec: "exit 0"
      -> false.should.be.true()
      next

  they 'should fail if command fail', (ssh, next) ->
    conditions.unless_exec.call nikita(),
      ssh: ssh
      unless_exec: "exit 1"
      -> next()
      () -> false.should.be.true()

  they 'should fail if at least one command succeed', (ssh, next) ->
    conditions.unless_exec.call nikita(),
      ssh: ssh
      unless_exec: [
        "exit 1"
        "exit 0"
        "exit 1"
      ]
      -> false.should.be.true()
      next

  they 'should succeed if all commands fail', (ssh, next) ->
    conditions.unless_exec.call nikita(),
      ssh: ssh
      unless_exec: [
        "exit 1"
        "exit 1"
        "exit 1"
      ]
      -> next()
      (err) -> false.should.be.true()
