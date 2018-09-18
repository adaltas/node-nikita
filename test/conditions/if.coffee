
conditions = require '../../src/misc/conditions'
{tags} = require '../test'

return unless tags.api

describe 'if', ->

  # it 'bypass if not present', (next) ->
  #   conditions.if
  #     ssh: ssh
  #     () -> false.should.be.true()
  #     next

  it 'succeed if `true`', (next) ->
    conditions.if
      options:
        if: true
      next
      () -> false.should.be.true()

  it 'succeed if `1`', (next) ->
    conditions.if
      options:
        if: 1
      next
      () -> false.should.be.true()

  it 'succeed if buffer and length > 1', (next) ->
    conditions.if
      options:
        if: Buffer.from 'abc'
      next
      () -> false.should.be.true()

  it 'fail if buffer and length is 0', (next) ->
    conditions.if
      options:
        if: Buffer.from ''
      () -> false.should.be.true()
      next

  it 'fail if `false`', (next) ->
    conditions.if
      options:
        if: false
      () -> false.should.be.true()
      next

  it 'fail if `null`', (next) ->
    conditions.if
      options:
        if: null
      () -> false.should.be.true()
      next

  it 'fail if `undefined`', (next) ->
    conditions.if
      options:
        if: undefined
      () -> false.should.be.true()
      next

  it 'succeed if string not empty', (next) ->
    conditions.if
      options:
        if: 'abc'
      next
      () -> false.should.be.true()

  it 'succeed if template string not empty', (next) ->
    conditions.if
      options:
        if: '{{options.db.test}}'
        db: test: 'abc'
      next
      () -> false.should.be.true()

  it 'fail if string empty', (next) ->
    conditions.if
      options:
        if: ''
      () -> false.should.be.true()
      next

  it 'fail if template string empty', (next) ->
    conditions.if
      options:
        if: '{{options.db.test}}'
      db: test: ''
      () -> false.should.be.true()
      next

  it 'function pass options', (next) ->
    conditions.if
      options:
        if: ({options}) ->
          options.a_key.should.eql 'a value'
        a_key: 'a value'
      next
      (err) -> false.should.be.true()

  it 'function is sync with 0 arguments', (next) ->
    called = false
    conditions.if
      options:
        if: -> called = true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  it 'function is sync with 1 arguments', (next) ->
    called = false
    conditions.if
      options:
        if: -> called = true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  it 'succeed if function is sync and return false', (next) ->
    conditions.if
      options:
        if: -> false
      () -> false.should.be.true()
      next

  it 'succed if function is async and pass true', (next) ->
    called = true
    conditions.if
      options:
        if: ({}, calback) -> calback null, true
      ->
        called.should.be.true()
        next()
      (err) -> false.should.be.true()

  it 'fail if function is async and pass false', (next) ->
    conditions.if
      options:
        if: ({}, callback) -> callback null, false
      () -> false.should.be.true()
      next

  it 'function pass error object on `failed` callback', (next) ->
    conditions.if
      options:
        if: ({}, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

  describe 'error', ->

    it 'fail if an object', (next) ->
      conditions.if
        options:
          if: {}
        () -> false.should.be.true()
        (err) ->
          err.message.should.eql "Invalid condition \"if\": {}"
          next()

describe 'unless', ->

  # it 'bypass if not present', (next) ->
  #   conditions.unless
  #     {}
  #     next
  #     () -> false.should.be.true()

  it 'succeed if `true`', (next) ->
    conditions.unless
      options:
        unless: true
      () -> false.should.be.true()
      next

  it 'skip if all true', (next) ->
    conditions.unless
      options:
        unless: [true, true, true]
      () -> false.should.be.true()
      next

  it 'skip if at least one is true', (next) ->
    conditions.unless
      options:
        unless: [false, true, false]
      () -> false.should.be.true()
      next

  it 'run if all false', (next) ->
    conditions.unless
      options:
        unless: [false, false, false]
      next
      () -> false.should.be.true()

  it 'succeed if `1`', (next) ->
    conditions.unless
      options:
        unless: 1
      () -> false.should.be.true()
      next

  it 'succeed if buffer and length > 1', (next) ->
    conditions.unless
      options:
        unless: Buffer.from 'abc'
      () -> false.should.be.true()
      next

  it 'fail if buffer and length is 0', (next) ->
    conditions.unless
      options:
        unless: Buffer.from ''
      next
      () -> false.should.be.true()

  it 'fail if `false`', (next) ->
    conditions.unless
      options:
        unless: false
      next
      () -> false.should.be.true()

  it 'fail if `null`', (next) ->
    conditions.unless
      options:
        unless: null
      next
      () -> false.should.be.true()

  it 'fail if string not empty', (next) ->
    conditions.unless
      options:
        unless: 'abc'
      () -> false.should.be.true()
      next

  it 'fail if string not empty', (next) ->
    conditions.unless
      options:
        unless: ''
      next
      () -> false.should.be.true()

  it 'function succeed on `succeed` callback', (next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback null, true
      () -> false.should.be.true()
      next

  it 'function fail on `failed` callback', (next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback null, false
      next
      () -> false.should.be.true()

  it 'function pass error object on `failed` callback', (next) ->
    conditions.unless
      options:
        unless: ({}, callback) -> callback new Error 'cool'
      () -> false.should.be.true()
      (err) -> err.message is 'cool' and next()

  describe 'error', ->

    it 'fail if an object', (next) ->
      conditions.unless
        options:
          unless: {}
        () -> false.should.be.true()
        (err) ->
          err.message.should.eql "Invalid condition \"unless\": {}"
          next()
