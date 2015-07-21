
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise status', ->

  it 'get status', (next) ->
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

  it 'get current status', (next) ->
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

  it 'get previous status', (next) ->
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
