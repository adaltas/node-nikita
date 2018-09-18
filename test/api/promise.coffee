
nikita = require '../../src'
fs = require 'fs'
{tags} = require '../test'

return unless tags.api

describe 'api promise', ->

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
  
  it 'handle nested sessions', ->
    callback_is_called = false
    nikita
    .call (_, callback) ->
      nikita
      .next (err, changed) ->
        callback_is_called = true
        callback err
    .next ->
      true.should.be.true()
    .promise()
