
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'status', ->

  it 'get without arguments', (next) ->
    mecano
    .call (options, callback) ->
      @status().should.be.false()
      callback null, false
    , (err, status) ->
      @status().should.be.false()
    .call (options, callback) ->
      @status().should.be.false()
      callback null, true
    .call (options, callback) ->
      @status().should.be.true()
      callback null, false
    .call (options, callback) ->
      @status().should.be.true()
      callback null, false
    .then next

  it 'get current', (next) ->
    mecano
    .call (options, callback) ->
      (@status(0) is undefined).should.be.true()
      callback null, false
    , (err, status) ->
      @status(0).should.be.false()
    .call (options, callback) ->
      (@status(0) is undefined).should.be.true()
      callback null, true
    , (err, status) ->
      @status(0).should.be.true()
    .then next

  it 'get previous', (next) ->
    mecano
    .call (options, callback) ->
      (@status(-1) is undefined).should.be.true()
      callback null, false
    , (err, status) ->
      (@status(-1) is undefined).should.be.true()
    .call (options, callback) ->
      @status(-1).should.be.false()
      callback null, true
    .call (options, callback) ->
      @status(-1).should.be.true()
      callback null, false
    .call (options, callback) ->
      @status(-1).should.be.false()
      callback null, false
    .then next

  it 'get previous n', (next) ->
    mecano
    .call (options, callback) ->
      callback null, false
    .call (options, callback) ->
      (@status(0) is undefined).should.be.true()
      @status(-1).should.be.false()
      callback null, false
    , (err, status) ->
      @status(0).should.be.false()
      @status(-1).should.be.false()
    .call (options, callback) ->
      callback null, true
    , (err, status) ->
      @status(0).should.be.true()
      @status(-1).should.be.false()
      @status(-2).should.be.false()
    .call (options, callback) ->
      (@status(0) is undefined).should.be.true()
      @status(-1).should.be.true()
      @status(-2).should.be.false()
      callback null, false
    .then next

  it 'report conditions', (next) ->
    mecano
    .call
      if: -> true
    , (options, callback) ->
      callback null, true
    .then (err, status) ->
      return next err if err
      status.should.be.true()
    .call
      if: -> false
    , (options, callback) ->
      callback null, true
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      next()

  it 'retrieve inside conditions', (next) ->
    mecano
    .call
      if: -> @status()
    , (options, callback) -> 
      callback Error 'Shouldnt be called' 
    .call (options, callback) ->
      callback null, true
    .call
      if: -> @status()
    , (options, callback) ->
      # Must be called
      next()




