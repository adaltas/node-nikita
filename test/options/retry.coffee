
nikita = require '../../src'
fs = require 'fs'

describe 'options "retry"', ->

  it 'stop once errorless', (next) ->
    count = 0
    nikita
    .call retry: 5, wait: 500, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme' if options.attempt < 2
    .then (err) ->
      count.should.eql 3
      next err

  it 'retry x times', (next) ->
    count = 0
    nikita
    .call retry: 3, wait: 500, (options) ->
      options.attempt.should.eql count++
      throw Error 'Catchme'
    .then (err) ->
      err.message.should.eql 'Catchme'
      count.should.eql 3
      next()

  it 'retry x times', (next) ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log.message if /^Retry/.test log.message
    .call retry: 2, wait: 500, (options) ->
      throw Error 'Catchme'
    .then ->
      logs.should.eql ['Retry on error, attempt 1']
      next()
      
