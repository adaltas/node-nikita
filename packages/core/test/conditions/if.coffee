
nikita = require '../../src'
conditions = require '../../src/misc/conditions'
{tags} = require '../test'

return unless tags.api

describe 'if', ->

  # it 'bypass if not present', (next) ->
  #   conditions.if
  #     ssh: ssh
  #     () -> false.should.be.true()
  #     next

  it 'succeed if `true`', ->
    count = 0
    nikita
    .call
      if: true
    , ->
      count++
    .call ->
      count.should.equal 1
    .promise()

  it 'succeed if `1`', ->
    count = 0
    nikita
    .call
      if: 1
    , ->
      count++
    .call ->
      count.should.equal 1
    .promise()

  it 'succeed if buffer and length > 1', ->
    count = 0
    nikita
    .call
      if: Buffer.from 'abc'
    , ->
      count++
    .call ->
      count.should.equal 1
    .promise()

  it 'fail if buffer and length is 0', ->
    nikita
    .call
      if: Buffer.from ''
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'fail if `false`', ->
    nikita
    .call
      if: false
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'fail if `null`', ->
    nikita
    .call
      if: null
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'fail if `undefined`', ->
    nikita
    .call
      if: undefined
    , ->
      throw Error 'You are not welcome here'
    .promise()
  
  it 'succeed if string not empty', ->
    count = 0
    nikita
    .call
      if: 'abc'
    , ->
      count++
    .call ->
      count.should.equal 1
    .promise()

  it 'succeed if template string not empty', ->
    count = 0
    nikita
    .call
      if: '{{options.db.test}}'
      db: test: 'abc'
    , ->
      count++
    .call ->
      count.should.equal 1
    .promise()

  it 'fail if string empty', ->
    nikita
    .call
      if: ''
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'fail if template string empty',->
    nikita
    .call
      if: '{{options.db.test}}'
      db: test: ''
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'function pass options', ->
    nikita
    .call
      if: ({options}) ->
        options.a_key.should.eql 'a value'
      a_key: 'a value'
    , (->) 
    .promise()

  it 'function is sync with 0 arguments', ->
    called = 0
    nikita
    .call
      if: ->
        called++
        true
    , ->
      called++
    .call ->
      called.should.equal 2
    .promise()

  it 'function is sync with 1 arguments', ->
    called = 0
    nikita
    .call
      if: ({options}) ->
        called++ if options.test
        true
      test: true
    , ->
      called++
    .call ->
      called.should.equal 2
    .promise()

  it 'succeed if function is sync and return false', ->
    nikita
    .call
      if: -> false
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'succed if function is async and pass true', ->
    called = 0
    nikita
    .call
      if: ({}, callback)->
        called++
        callback null, true
    , ->
      called++
    .call ->
      called.should.eql 2
    .promise()

  it 'fail if function is async and pass false', ->
    nikita
    .call
      if: ({}, callback) ->
        callback null, false
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'function pass error object on `failed` callback', ->
    nikita
    .call
      if: ({}, callback) ->
        callback new Error 'cool'
    , ->
      throw Error 'You are not welcome here'
    .next (err) ->
      err.message is 'cool'
    .promise()
    
  describe 'error', ->

    it 'fail if an object', ->
      nikita
      .call
        if: {}
      , ->
        throw Error 'You are not welcome here'
      .next (err) ->
        err.message is 'Invalid condition "if": {}'
      .promise()

describe 'unless', ->

  # it 'bypass if not present', (next) ->
  #   conditions.unless
  #     {}
  #     next
  #     () -> false.should.be.true()

  it 'succeed if `true`', ->
    nikita
    .call
      unless: true
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'skip if all true', ->
    nikita
    .call
      unless: [true, true, true]
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'skip if at least one is true', ->
    nikita
    .call
      unless: [false, true, false]
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'run if all false', ->
    count = 0
    nikita
    .call
      unless: [false, false, false]
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'skip if `1`', ->
    nikita
    .call
      unless: 1
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'run if `0`', ->
    count = 0
    nikita
    .call
      unless: 0
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'succeed if buffer and length > 1', ->
    nikita
    .call
      unless: Buffer.from 'abc'
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'run if buffer and length is 0', ->
    count = 0
    nikita
    .call
      unless: Buffer.from ''
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'run if `false`', ->
    count = 0
    nikita
    .call
      unless: false
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'run if `null`', ->
    count = 0
    nikita
    .call
      unless: null
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'skip if string not empty', ->
    nikita
    .call
      unless: 'abc'
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'run if string empty', ->
    count = 0
    nikita
    .call
      unless: ''
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'skip on `positive` callback', ->
    nikita
    .call
      unless: ({}, callback) -> callback null, true
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it 'run on `negative` callback', ->
    count = 0
    nikita
    .call
      unless: ({}, callback) -> callback null, false
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it 'function pass error object on `failed` callback', ->
    nikita
    .call
      unless: ({}, callback) -> callback new Error 'Cool'
    , ->
      throw Error 'You are not welcome here'
    .next (err) ->
      err.message.should.eql 'Cool'
    .promise()

  describe 'error', ->

    it 'fail if an object', ->
      nikita
      .call
        unless: {}
      , ->
        throw Error 'You are not welcome here'
      .next (err) ->
        err.message.should.eql 'Invalid condition "unless": {}'
      .promise()
