
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise shy', ->

  scratch = test.scratch @

  it 'dont alter status', (next) ->
    mecano
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
    .then (err, status) ->
      status.should.be.False
      next()
        






