
mecano = require '../../src'
test = require '../test'

describe 'api error', ->

  scratch = test.scratch @

  it 'log', (next) ->
    logs = []
    mecano
    .on 'text', (log) -> logs.push log
    .call -> throw Error 'Catchme'
    .then (err) ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
      next()

  it 'log with relax', (next) ->
    logs = []
    mecano
    .on 'text', (log) -> logs.push log
    .call relax: true, -> throw Error 'Catchme'
    .then (err) ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
      next()
