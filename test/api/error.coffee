
nikita = require '../../src'
test = require '../test'

describe 'api error', ->

  it 'log', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log
    .call -> throw Error 'Catchme'
    .then ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
    .promise()

  it 'log with relax', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log
    .call relax: true, -> throw Error 'Catchme'
    .call ->
      logs.length.should.eql 1
      logs[0].message.should.eql 'Catchme'
      logs[0].level.should.eql 'ERROR'
    .promise()
