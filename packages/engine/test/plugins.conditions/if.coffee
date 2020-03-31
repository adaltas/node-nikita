
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
    
  describe 'object', ->

    it 'run if `{k:v}`', ->
      nikita.call
        if: {k:"v"}
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if `{}`', ->
      nikita.call
        if: {}
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
    
