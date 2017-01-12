
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'

describe 'if', ->

  # they 'bypass if not present', (ssh, next) ->
  #   conditions.if
  #     ssh: ssh
  #     () -> false.should.be.true()
  #     next

  they 'succeed if `true`', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: true
      next
      () -> false.should.be.true()

  they 'succeed if `1`', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: 1
      next
      () -> false.should.be.true()
  
  they 'succeed if buffer and length > 1', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: Buffer.from 'abc'
      next
      () -> false.should.be.true()
  
  they 'fail if buffer and length is 0', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: Buffer.from ''
      () -> false.should.be.true()
      next

  they 'fail if `false`', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: false
      () -> false.should.be.true()
      next

  they 'fail if `null`', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: null
      () -> false.should.be.true()
      next

  they 'fail if `undefined`', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: undefined
      () -> false.should.be.true()
      next

  they 'succeed if string not empty', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: 'abc'
      next
      () -> false.should.be.true()

  they 'succeed if template string not empty', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: '{{db.test}}'
      db: test: 'abc'
      next
      () -> false.should.be.true()

  they 'fail if string empty', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: ''
      () -> false.should.be.true()
      next

  they 'fail if template string empty', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: '{{db.test}}'
      db: test: ''
      () -> false.should.be.true()
      next

  they 'succeed on `succeed` sync callback 0 arguments', (ssh, next) ->
    called = true
    conditions.if
      ssh: ssh
      if: -> true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'succeed on `succeed` sync callback 1 arguments', (ssh, next) ->
    called = true
    conditions.if
      ssh: ssh
      if: (options) -> true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'fail on `failed` sync callback', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: (options) -> false
      () -> false.should.be.true()
      next

  they 'succeed on `succeed` async callback', (ssh, next) ->
    called = true
    conditions.if
      ssh: ssh
      if: (options, calback) -> calback null, true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'fail on `failed` callback', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: (options, callback) -> callback null, false
      () -> false.should.be.true()
      next

  they 'pass error object on `failed` callback', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: (options, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

  they 'call callback with single argument', (ssh, next) ->
    conditions.if
      ssh: ssh
      if: (options, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

describe 'unless', ->

  # they 'bypass if not present', (ssh, next) ->
  #   conditions.unless
  #     ssh: ssh
  #     next
  #     () -> false.should.be.true()

  they 'succeed if `true`', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: true
      () -> false.should.be.true()
      next

  they 'skip if all true', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: [true, true, true]
      () -> false.should.be.true()
      next

  they 'skip if at least one is true', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: [false, true, false]
      () -> false.should.be.true()
      next

  they 'run if all false', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: [false, false, false]
      next
      () -> false.should.be.true()

  they 'succeed if `1`', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: 1
      () -> false.should.be.true()
      next
  
  they 'succeed if buffer and length > 1', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: Buffer.from 'abc'
      () -> false.should.be.true()
      next
  
  they 'fail if buffer and length is 0', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: Buffer.from ''
      next
      () -> false.should.be.true()

  they 'fail if `false`', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: false
      next
      () -> false.should.be.true()

  they 'fail if `null`', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: null
      next
      () -> false.should.be.true()

  they 'fail if string not empty', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: 'abc'
      () -> false.should.be.true()
      next

  they 'fail if string not empty', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: ''
      next
      () -> false.should.be.true()

  they 'function succeed on `succeed` callback', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: (options, callback) -> callback null, true
      () -> false.should.be.true()
      next

  they 'function fail on `failed` callback', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: (options, callback) -> callback null, false
      next
      () -> false.should.be.true()

  they 'function pass error object on `failed` callback', (ssh, next) ->
    conditions.unless
      ssh: ssh
      unless: (options, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()
