
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
      options:
        if: true
      next
      () -> false.should.be.true()

  they 'succeed if `1`', (ssh, next) ->
    conditions.if
      options:
        if: 1
      next
      () -> false.should.be.true()

  they 'succeed if buffer and length > 1', (ssh, next) ->
    conditions.if
      options:
        if: Buffer.from 'abc'
      next
      () -> false.should.be.true()

  they 'fail if buffer and length is 0', (ssh, next) ->
    conditions.if
      options:
        if: Buffer.from ''
      () -> false.should.be.true()
      next

  they 'fail if `false`', (ssh, next) ->
    conditions.if
      options:
        if: false
      () -> false.should.be.true()
      next

  they 'fail if `null`', (ssh, next) ->
    conditions.if
      options:
        if: null
      () -> false.should.be.true()
      next

  they 'fail if `undefined`', (ssh, next) ->
    conditions.if
      options:
        if: undefined
      () -> false.should.be.true()
      next

  they 'succeed if string not empty', (ssh, next) ->
    conditions.if
      options:
        if: 'abc'
      next
      () -> false.should.be.true()

  they 'succeed if template string not empty', (ssh, next) ->
    conditions.if
      options:
        if: '{{options.db.test}}'
        db: test: 'abc'
      next
      () -> false.should.be.true()

  they 'fail if string empty', (ssh, next) ->
    conditions.if
      options:
        if: ''
      () -> false.should.be.true()
      next

  they 'fail if template string empty', (ssh, next) ->
    conditions.if
      options:
        if: '{{options.db.test}}'
      db: test: ''
      () -> false.should.be.true()
      next

  they 'function pass options', (ssh, next) ->
    conditions.if
      options:
        if: ({options}) ->
          options.a_key.should.eql 'a value'
        a_key: 'a value'
      next
      (err) -> false.should.be.true()

  they 'function is sync with 0 arguments', (ssh, next) ->
    called = false
    conditions.if
      options:
        if: -> called = true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'function is sync with 1 arguments', (ssh, next) ->
    called = false
    conditions.if
      options:
        if: -> called = true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'succeed if function is sync and return false', (ssh, next) ->
    conditions.if
      options:
        if: -> false
      () -> false.should.be.true()
      next

  they 'succed if function is async and pass true', (ssh, next) ->
    called = true
    conditions.if
      options:
        if: ({}, calback) -> calback null, true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  they 'fail if function is async and pass false', (ssh, next) ->
    conditions.if
      options:
        if: ({}, callback) -> callback null, false
      () -> false.should.be.true()
      next

  they 'function pass error object on `failed` callback', (ssh, next) ->
    conditions.if
      options:
        if: ({}, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

  describe 'error', ->

    they 'fail if an object', (ssh, next) ->
      conditions.if
        options:
          if: {}
        () -> false.should.be.true()
        (err) ->
          err.message.should.eql "Invalid condition \"if\": {}"
          next()

describe 'unless', ->

  # they 'bypass if not present', (ssh, next) ->
  #   conditions.unless
  #     {}
  #     next
  #     () -> false.should.be.true()

  they 'succeed if `true`', (ssh, next) ->
    conditions.unless
      options:
        unless: true
      () -> false.should.be.true()
      next

  they 'skip if all true', (ssh, next) ->
    conditions.unless
      options:
        unless: [true, true, true]
      () -> false.should.be.true()
      next

  they 'skip if at least one is true', (ssh, next) ->
    conditions.unless
      options:
        unless: [false, true, false]
      () -> false.should.be.true()
      next

  they 'run if all false', (ssh, next) ->
    conditions.unless
      options:
        unless: [false, false, false]
      next
      () -> false.should.be.true()

  they 'succeed if `1`', (ssh, next) ->
    conditions.unless
      options:
        unless: 1
      () -> false.should.be.true()
      next

  they 'succeed if buffer and length > 1', (ssh, next) ->
    conditions.unless
      options:
        unless: Buffer.from 'abc'
      () -> false.should.be.true()
      next

  they 'fail if buffer and length is 0', (ssh, next) ->
    conditions.unless
      options:
        unless: Buffer.from ''
      next
      () -> false.should.be.true()

  they 'fail if `false`', (ssh, next) ->
    conditions.unless
      options:
        unless: false
      next
      () -> false.should.be.true()

  they 'fail if `null`', (ssh, next) ->
    conditions.unless
      options:
        unless: null
      next
      () -> false.should.be.true()

  they 'fail if string not empty', (ssh, next) ->
    conditions.unless
      options:
        unless: 'abc'
      () -> false.should.be.true()
      next

  they 'fail if string not empty', (ssh, next) ->
    conditions.unless
      options:
        unless: ''
      next
      () -> false.should.be.true()

  they 'function succeed on `succeed` callback', (ssh, next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback null, true
      () -> false.should.be.true()
      next

  they 'function fail on `failed` callback', (ssh, next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback null, false
      next
      () -> false.should.be.true()

  they 'function pass error object on `failed` callback', (ssh, next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

  describe 'error', ->

    they 'fail if an object', (ssh, next) ->
      conditions.unless
        options:
          unless: {}
        () -> false.should.be.true()
        (err) ->
          err.message.should.eql "Invalid condition \"unless\": {}"
          next()
