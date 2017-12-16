
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "sleep"', ->

  scratch = test.scratch @
  
  it 'enforce default to 3s', ->
    times = []
    nikita
    .call retry: 2, relax: true, (options) ->
      times.push Date.now()
      throw Error 'Catchme'
    .next (err) ->
      times.length.should.eql 2
      ((times[1] - times[0]) / 1000 - 3).should.be.below 0.01
    .promise()

  it 'is set by user', ->
    times = []
    nikita
    .call sleep: 1, retry: 2, relax: true, (options) ->
      times.push Date.now()
      throw Error 'Catchme'
    .next (err) ->
      times.length.should.eql 2
      ((times[1] - times[0]) / 1000 - 1).should.be.below 0.01
    .promise()
  
  it 'ensure sleep is a number', ->
    nikita
    .call sleep: 'a string', (->)
    .next (err) ->
      err.message.should.eql 'Invalid options sleep, got "a string"'
    .promise()
  
  it 'ensure sleep equals or is greater than 0', ->
    nikita
    .call sleep: 0, (->)
    .call sleep: 1, (->)
    .call sleep: -1, (->)
    .next (err) ->
      err.message.should.eql 'Invalid options sleep, got -1'
    .promise()
