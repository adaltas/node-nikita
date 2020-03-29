
nikita = require '../../src'

describe 'if', ->

  it 'boolean true - success', ->
    nikita.call
      if: true
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'boolean false - failure', ->
    nikita.call
      if: false
    , ->
      throw Error 'Handler is not expected to be called'

  it 'integer 1 - success', ->
    output = await nikita.call
      if: 1
    , -> 'called'
    output.should.eql 'called'

  it 'boolean 0 - failure', ->
    nikita.call
      if: 0
    , ->
      throw Error 'Handler is not expected to be called'

  it 'fail if `null`', ->
    nikita
    .call
      if: null
    , ->
      throw Error 'You are not welcome here'

  it 'fail if `undefined`', ->
    nikita
    .call
      if: undefined
    , ->
      throw Error 'Handler is not expected to be called'
  
  describe 'string + buffer', ->
  
    it 'succeed if string not empty', ->
      nikita.call
        if: 'abc'
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it.skip 'succeed if template string not empty', ->
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

    it.skip 'fail if string empty', ->
      nikita
      .call
        if: ''
      , ->
        throw Error 'You are not welcome here'
      .promise()

    it.skip 'fail if template string empty',->
      nikita
      .call
        if: '{{options.db.test}}'
        db: test: ''
      , ->
        throw Error 'You are not welcome here'
      .promise()

    it 'buffer with content - sucess', ->
      output = await nikita.call
        if: Buffer.from 'abc'
      , -> 'called'
      output.should.eql 'called'

    it 'buffer empty - failure', ->
      nikita
      .call
        if: Buffer.from ''
      , ->
        throw Error 'You are not welcome here'
  
  describe 'function', ->

    it 'function execute handler if return true', ->
      called = 0
      nikita
      .call
        if: ->
          called++
          true
        handler: ->
          called++
      .call ->
        called.should.equal 2

    it 'function skip handler if return true', ->
      called = 0
      nikita
      .call
        if: ->
          called++
          false
        handler: ->
          throw Error 'You are not welcome here'
      .call ->
        called.should.equal 1

    it 'function pass options', ->
      nikita.call
        if: ({options}) ->
          options.a_key.should.eql 'a value'
        a_key: 'a value'
        handler: -> 'success'
      .should.be.finally.eql 'success'
    
  describe 'error', ->

    it.skip 'fail if an object', ->
      nikita
      .call
        if: {}
      , ->
        throw Error 'You are not welcome here'
      .next (err) ->
        err.message is 'Invalid condition "if": {}'
      .promise()

describe 'unless', ->

  # it.skip 'bypass if not present', (next) ->
  #   conditions.unless
  #     {}
  #     next
  #     () -> false.should.be.true()

  it.skip 'succeed if `true`', ->
    nikita
    .call
      unless: true
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'skip if all true', ->
    nikita
    .call
      unless: [true, true, true]
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'skip if at least one is true', ->
    nikita
    .call
      unless: [false, true, false]
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'run if all false', ->
    count = 0
    nikita
    .call
      unless: [false, false, false]
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'skip if `1`', ->
    nikita
    .call
      unless: 1
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'run if `0`', ->
    count = 0
    nikita
    .call
      unless: 0
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'succeed if buffer and length > 1', ->
    nikita
    .call
      unless: Buffer.from 'abc'
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'run if buffer and length is 0', ->
    count = 0
    nikita
    .call
      unless: Buffer.from ''
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'run if `false`', ->
    count = 0
    nikita
    .call
      unless: false
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'run if `null`', ->
    count = 0
    nikita
    .call
      unless: null
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'skip if string not empty', ->
    nikita
    .call
      unless: 'abc'
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'run if string empty', ->
    count = 0
    nikita
    .call
      unless: ''
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'skip on `positive` callback', ->
    nikita
    .call
      unless: ({}, callback) -> callback null, true
    , ->
      throw Error 'You are not welcome here'
    .promise()

  it.skip 'run on `negative` callback', ->
    count = 0
    nikita
    .call
      unless: ({}, callback) -> callback null, false
    , ->
      count++
    .call ->
      count.should.eql 1
    .promise()

  it.skip 'function pass error object on `failed` callback', ->
    nikita
    .call
      unless: ({}, callback) -> callback new Error 'Cool'
    , ->
      throw Error 'You are not welcome here'
    .next (err) ->
      err.message.should.eql 'Cool'
    .promise()

  describe 'error', ->

    it.skip 'fail if an object', ->
      nikita
      .call
        unless: {}
      , ->
        throw Error 'You are not welcome here'
      .next (err) ->
        err.message.should.eql 'Invalid condition "unless": {}'
      .promise()
