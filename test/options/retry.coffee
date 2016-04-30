
mecano = require '../../src'
fs = require 'fs'

describe 'options retry', ->

  it 'stop once errorless', (next) ->
    count = 0
    mecano
    .call retry: 5, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme' if options.attempt < 2
    .then (err) ->
      count.should.eql 3
      next err

  it 'retry x times', (next) ->
    count = 0
    mecano
    .call retry: 3, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme'
    .then (err) ->
      err.message.should.eql 'Catchme'
      count.should.eql 3
      next()
      
