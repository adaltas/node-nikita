
mecano = require '../../src'
fs = require 'fs'

describe 'api handler', ->

  describe 'usage', ->

    it 'is an option', (next) ->
      history = []
      mecano
      .call
        handler: ->
          history.push 'a'
      .call
        handler: (_, callback) ->
          history.push 'b'
          callback()
      .call ->
        history.should.eql ['a', 'b']
      .then next

  describe 'error', ->

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

    it 'throw in async action', (next) ->
      m = mecano()
      m.register 'anaction', (options, callback) ->
        setImmediate -> callback Error 'Catchme'
      m
      .anaction
        key: "value"
      , (err, written) ->
        err.message.should.eql 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()
