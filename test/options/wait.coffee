
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options wait', ->

  scratch = test.scratch @
  
  it 'enforce default to 3s', (next) ->
    times = []
    mecano
    .call retry: 2, relax: true, (options) ->
      times.push Date.now()
      throw Error 'Catchme'
    .then (err) ->
      times.length.should.eql 2
      ((times[1] - times[0]) / 1000 - 3).should.be.below 0.01
      next err
      
  it 'is set by user', (next) ->
    times = []
    mecano
    .call wait: 1, retry: 2, relax: true, (options) ->
      times.push Date.now()
      throw Error 'Catchme'
    .then (err) ->
      times.length.should.eql 2
      ((times[1] - times[0]) / 1000 - 1).should.be.below 0.01
      next err
  
  it 'ensure wait is a number', (next) ->
    mecano
    .call wait: 'a string', (->)
    .then (err) ->
      err.message.should.eql 'Invalid options wait, got "a string"'
      next()
  
  it 'ensure wait equals or is greater than 0', (next) ->
    mecano
    .call wait: 0, (->)
    .call wait: 1, (->)
    .call wait: -1, (->)
    .then (err) ->
      err.message.should.eql 'Invalid options wait, got -1'
      next()
      
