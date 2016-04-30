
mecano = require '../../src'
fs = require 'fs'

describe 'options handler', ->

  describe 'sync', ->

    it 'is an option', (next) ->
      history = []
      mecano
      .call
        handler: ->  history.push 'a'
      .call
        handler: (_, callback) ->
          history.push 'b'
          callback()
      .call ->
        history.should.eql ['a', 'b']
      .then next

  describe 'error sync', ->

    it 'throw in sync action', (next) ->
      m = mecano()
      m.register 'anaction', (options, callback) ->
        throw Error 'Catchme'
      m
      .anaction
        key: "value"
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'throw after registered function', (next) ->
      mecano()
      .call ->
        @call fuck: 'yeah', ->
        throw Error 'Catchme'
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

  describe 'error async', ->

    it 'passed as argument in same tick', (next) ->
      m = mecano()
      m.register 'anaction', (options, callback) ->
        callback Error 'Catchme'
      m
      .anaction
        key: "value"
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'passed as argument', (next) ->
      m = mecano()
      m.register 'anaction', (options, callback) ->
        process.nextTick -> callback Error 'Catchme'
      m
      .anaction
        key: "value"
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'thrown', (next) ->
      mecano
      .call (options, next) ->
        throw Error 'Catchme'
      .then (err, status) ->
        err.message.should.eql 'Catchme'
        next()

    it 'throw after registered function', (next) ->
      mecano()
      .call (_, callback) ->
        @call fuck: 'yeah', ->
        throw Error 'Catchme'
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'handler called multiple times', (next) ->
      mecano
      .call
        handler: (_, callback) ->
          callback()
          setImmediate -> 
            callback()
      .call ->
        setImmediate ->
          next Error 'Shouldnt be called'
      .then (err, status) ->
        err.message.should.eql 'Multiple call detected'
        next()
