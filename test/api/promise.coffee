
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
    nikita
    .call (_, callback) ->
      setImmediate -> callback Error 'CatchMe'
    .promise()
    .then () ->
      next Error 'Promise was expected to be rejected'
    , (err) ->
      err.message.should.eql 'CatchMe'
      next()
        
