
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'

describe 'if_exec', ->

  they 'should succeed if command succeed', (ssh, next) ->
    conditions.if_exec
      ssh: ssh
      if_exec: "exit 0"
      (err) -> false.should.be.true()
      -> next()

  they 'should fail if command succeed', (ssh, next) ->
    conditions.if_exec
      ssh: ssh
      if_exec: "exit 1"
      () -> next()
      -> false.should.be.true()

  they 'should fail if at least one command fail', (ssh, next) ->
    conditions.if_exec
      ssh: ssh
      if_exec: [
        "exit 0"
        "exit 1"
        "exit 0"
      ]
      next
      -> false.should.be.true()

  they 'should succeed if all commands succeeed', (ssh, next) ->
    conditions.if_exec
      ssh: ssh
      if_exec: [
        "exit 0"
        "exit 0"
        "exit 0"
      ]
      (err) -> false.should.be.true()
      -> next()

describe 'not_if_exec', ->

  they 'should succeed if command fail', (ssh, next) ->
    conditions.not_if_exec
      ssh: ssh
      not_if_exec: "exit 0"
      next
      -> false.should.be.true()

  they 'should fail if command fail', (ssh, next) ->
    conditions.not_if_exec
      ssh: ssh
      not_if_exec: "exit 1"
      () -> false.should.be.true()
      -> next()

  they 'should fail if at least one command succeeed', (ssh, next) ->
    conditions.not_if_exec
      ssh: ssh
      not_if_exec: [
        "exit 1"
        "exit 0"
        "exit 1"
      ]
      next
      -> false.should.be.true()

  they 'should succeed if all commands fail', (ssh, next) ->
    conditions.not_if_exec
      ssh: ssh
      not_if_exec: [
        "exit 1"
        "exit 1"
        "exit 1"
      ]
      (err) -> false.should.be.true()
      -> next()





