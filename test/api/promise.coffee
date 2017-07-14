
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api promise', ->

  scratch = test.scratch @

  it 'call resolve', ->
    nikita
    .call (_, callback) ->
      setImmediate -> callback null, true
    .promise()

  it 'call reject', (next) ->
    setImmediate ->
      nikita
      .call (_, callback) ->
        setImmediate -> callback Error 'CatchMe'
      .promise()
      .then () ->
        next Error 'Promise was expected to be rejected'
      , (err) ->
        err.message.should.eql 'CatchMe'
        next()
  
  it 'handle nested context', ->
    callback_is_called = false
    nikita
    .call (_, callback) ->
      nikita
      .then (err, changed) ->
        callback_is_called = true
        callback err
      # setImmediate ->
      #   callback_is_called = true
      #   callback()
    .then ->
      console.log 'callback_is_called', callback_is_called
      true.should.be.true()
    .promise()
        
