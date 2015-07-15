
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise status', ->

  it 'get current status', (next) ->
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
