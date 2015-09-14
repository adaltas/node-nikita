
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api relax', ->

  scratch = test.scratch @

  it 'sync', (next) ->
    mecano
    .call relax: true, ->
      throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call ->
      @call relax: true, (_, callback) ->
        callback Error 'Dont cry, laugh outloud'
    .call ({}, callback) ->
      callback null, true
    .then (err, status) ->
      (err is null).should.be.true()
      status.should.be.true() unless err
      next()

  it 'async', (next) ->
    mecano
    .call relax: true, ({}, callback) ->
      setImmediate ->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call ({}, callback) ->
      callback null, true
    .then (err, status) ->
      (err is null).should.be.true()
      status.should.be.true() unless err
      next()
