
nikita = require '../../src'

describe 'plugin.condition if', ->

  it 'run if `true`', ->
    nikita.call
      if: true
      handler: -> 'called'
    .should.be.finally.eql 'called'

  it 'skip if `false`', ->
    nikita.call
      if: false
      handler: -> throw Error 'forbidden'

  it 'run if `1`', ->
    nikita.call
      if: 1
      handler: -> 'called'
    .should.finally.eql 'called'

  it 'skip if `0`', ->
    nikita.call
      if: 0
      handler: -> throw Error 'forbidden'

  it 'skip if `null`', ->
    nikita.call
      if: null
      handler: -> throw Error 'forbidden'

  it 'skip if `undefined`', ->
    nikita.call
      if: undefined
      handler: -> throw Error 'forbidden'
  
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
        if: '{{config.db.test}}'
        db: test: 'abc'
      , ->
        count++
      .call ->
        count.should.equal 1

    it 'skip if `""`', ->
      nikita.call
        if: ''
        handler: -> throw Error 'forbidden'

    it.skip 'skip if `{{""}}`',->
      nikita.call
        if: '{{config.db.test}}'
        db: test: ''
        handler: -> throw Error 'forbidden'

    it 'buffer with content - success', ->
      nikita.call
        if: Buffer.from 'abc'
        handler: -> 'called'
      .should.finally.eql 'called'

    it 'buffer empty - failure', ->
      nikita.call
        if: Buffer.from ''
        handler: -> throw Error 'forbidden'
    
  describe 'object', ->

    it 'run if `{k:v}`', ->
      nikita.call
        if: {k:"v"}
        handler: -> 'called'
      .should.be.finally.eql 'called'

    it 'skip if `{}`', ->
      nikita.call
        if: {}
        handler: -> throw Error 'forbidden'
  
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

    it 'function pass config', ->
      nikita.call
        if: ({config}) ->
          config.a_key.should.eql 'a value'
        a_key: 'a value'
        handler: -> 'success'
      .should.be.finally.eql 'success'
    
