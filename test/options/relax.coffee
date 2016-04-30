
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options relax', ->

  scratch = test.scratch @

  it 'sync', (next) ->
    mecano
    .call relax: true, ->
      throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call -> # with parent
      @call relax: true, (_, callback) ->
        callback Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont worry, laugh outloud'
    .call ({}, callback) ->
      callback null, true
    .then (err, status) ->
      (err is null).should.be.true()
      status.should.be.true() unless err
      next()

  it 'sync with error throw in child', (next) ->
    mecano
    .call relax: true, ->
      @call ->
        throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call relax: true, ->
      @call (_, callback)->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call -> # with parent
      @call relax: true, ->
        @call ->
          throw Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont worry, laugh outloud'
    .call -> # with parent
      @call relax: true, ->
        @call (_, callback) ->
          callback Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont worry, laugh outloud'
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
