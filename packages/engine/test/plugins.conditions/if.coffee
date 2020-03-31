
nikita = require '../../src'

describe 'if', ->

  it 'run if `true`', ->
    nikita.call
      if: true
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if `false`', ->
    nikita.call
      if: false
    , ->
      throw Error 'Handler is not expected to be called'

  it 'run if `1`', ->
    nikita.call
      if: 1
      handler: -> 'called'
    .should.finally.eql 'called'

  it 'skip if `0`', ->
    nikita.call
      if: 0
    , ->
      throw Error 'Handler is not expected to be called'

  it 'skip if `null`', ->
    nikita
    .call
      if: null
    , ->
      throw Error 'You are not welcome here'

  it 'skip if `undefined`', ->
    nikita
    .call
      if: undefined
    , ->
      throw Error 'Handler is not expected to be called'
  
  describe 'string + buffer', ->
  
    it 'run if `"string"`', ->
      nikita.call
        if: 'abc'
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it.skip 'run if `{{"string"}}`', ->
      count = 0
      nikita
      .call
        if: '{{options.db.test}}'
        db: test: 'abc'
      , ->
        count++
      .call ->
        count.should.equal 1

    it 'skip if `""`', ->
      nikita.call
        if: ''
        handler: -> throw Error 'You are not welcome here'

    it.skip 'skip if `{{""}}`',->
      nikita.call
        if: '{{options.db.test}}'
        db: test: ''
        handler: -> throw Error 'You are not welcome here'

    it 'buffer with content - sucess', ->
      nikita.call
        if: Buffer.from 'abc'
        handler: -> 'called'
      .should.finally.eql 'called'

    it 'buffer empty - failure', ->
      nikita.call
        if: Buffer.from ''
        handler: -> throw Error 'You are not welcome here'
  
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

  it 'skip if `true`', ->
    nikita.call
      unless: true
      handler: -> throw Error 'You are not welcome here'

  it 'skip if all true', ->
    nikita .call
      unless: [true, true, true]
      handler: -> throw Error 'You are not welcome here'

  it 'skip if at least one is true', ->
    nikita.call
      unless: [false, true, false]
      handler: -> throw Error 'You are not welcome here'

  it 'run if all false', ->
    nikita.call
      unless: [false, false, false]
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if `1`', ->
    nikita.call
      unless: 1
      handler: -> throw Error 'You are not welcome here'

  it 'run if `0`', ->
    nikita.call
      unless: 0
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'succeed if buffer and length > 1', ->
    nikita.call
      unless: Buffer.from 'abc'
      handler: -> throw Error 'You are not welcome here'

  it 'run if buffer and length is 0', ->
    nikita.call
      unless: Buffer.from ''
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'run if `false`', ->
    nikita.call
      unless: false
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'run if `null`', ->
    nikita.call
      unless: null
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if string not empty', ->
    nikita.call
      unless: 'abc'
      handler: -> throw Error 'You are not welcome here'

  it 'run if string empty', ->
    nikita.call
      unless: ''
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip on `positive` callback', ->
    nikita.call
      unless: ({}) ->
        new Promise (accept, reject) -> accept true
      handler: -> throw Error 'You are not welcome here'

  it 'run on `negative` callback', ->
    nikita.call
      unless: ({}) ->
        new Promise (accept, reject) -> accept false
      handler: -> 'called'
    .should.finally.eql 'called'

  it.skip 'function pass error object on `failed` callback', ->
    # CURRENT WORK
    nikita.call
      unless: ({}) ->
        new Promise (accept, reject) ->
          reject Error 'Cool'
      handler: throw Error 'You are not welcome here'
    .catch (err) ->
      err.message.should.eql 'Cool'

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
