
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api actions', ->

  scratch = test.scratch @

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
