
nikita = require '../../src'
test = require '../test'

describe 'api error', ->

  it 'log', (next) ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log
    .call -> throw Error 'Catchme'
    .then (err) ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
      next()

  it 'log with relax', (next) ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log
    .call relax: true, -> throw Error 'Catchme'
    .then (err) ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
      next()
