
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "handler"', ->
  
  describe 'context', ->

    it 'pass properties', ->
      nikita
      .call (context) ->
        Object.keys(context).should.eql ['action', 'original', 'options', 'session', 'handler', 'callback']
      .promise()

  describe 'sync', ->

    it 'is an option', ->
      history = []
      nikita
      .call
        handler: ->  history.push 'a'
      .call
        handler: (_, callback) ->
          history.push 'b'
          callback()
      .call ->
        history.should.eql ['a', 'b']
      .promise()

  describe 'error sync', ->

    it 'throw in sync action', ->
      nikita()
      .registry.register 'anaction', ({options}, callback) ->
        throw Error 'Catchme'
      .anaction
        key: "value"
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'throw after registered function', ->
      nikita()
      .call ->
        @call fuck: 'yeah', ->
        throw Error 'Catchme'
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

  describe 'error async', ->

    it 'passed as argument in same tick', ->
      nikita()
      .registry.register 'anaction', ({options}, callback) ->
        callback Error 'Catchme'
      .anaction
        key: "value"
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'passed as argument', ->
      nikita()
      .registry.register 'anaction', ({options}, callback) ->
        process.nextTick -> callback Error 'Catchme'
      .anaction
        key: "value"
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'thrown', ->
      nikita
      .call ({options}, next) ->
        throw Error 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'throw after registered function', ->
      nikita()
      .call (_, callback) ->
        @call fuck: 'yeah', ->
        throw Error 'Catchme'
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'pass an error as first argument', ->
      nikita()
      .call (_, callback) ->
        setImmediate ->
         callback Error 'Catchme'
      , (err) ->
        err.message.should.eql 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'enforce a valid error as first argument', ->
      nikita()
      .call (_, callback) ->
        setImmediate ->
         callback {message: 'not a valid error'}
      , (err) ->
        err.message.should.eql 'First argument not a valid error'
      .next (err) ->
        err.message.should.eql 'First argument not a valid error'
      .promise()

    it 'handler called multiple times', ->
      nikita
      .call
        handler: (_, callback) ->
          callback()
          setImmediate ->
            callback()
      .call ->
        setImmediate ->
          next Error 'Shouldnt be called'
      .next (err) ->
        err.message.should.eql 'Multiple call detected'
      .promise()

    it 'handler called multiple times with error', ->
      nikita
      .call
        handler: (_, callback) ->
          callback Error 'message 1'
          setImmediate ->
            callback Error 'message 1'
      .call ->
        setImmediate ->
          next Error 'Shouldnt be called'
      .next (err) ->
        err.message.should.eql 'Multiple call detected'
      .promise()
