
nikita = require '../../src'
fs = require 'fs'

describe 'options "attempt"', ->

  it 'start with value 0', ->
    count = 0
    nikita
    .call (options) ->
      options.attempt.should.eql 0
    .promise()

  it 'follow the number of retry', ->
    count = 0
    nikita
    .call retry: 5, sleep: 0, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme' if options.attempt < 4
    .promise()

  it 'reschedule attempt with relax', ->
    count = 0
    nikita
    .call retry: 3, relax: true, sleep: 0, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme'
    .call ->
      count.should.eql 3
    .promise()
