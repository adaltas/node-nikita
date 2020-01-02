
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "sleep"', ->
  
  it 'is a metadata', ->
    now = Date.now()
    nikita
    .call sleep: 1000, ({metadata}) ->
      metadata.sleep.should.eql 1000
    .promise()
  
  it 'enforce default to 3s', ->
    now = Date.now()
    nikita
    .call retry: 2, relax: true, ->
      throw Error 'Catchme'
    .next (err) ->
      (Date.now() - now).should.be.above 3000
      (Date.now() - now).should.be.below 3500
    .promise()

  it 'is set by user', ->
    times = []
    nikita
    .call sleep: 1, retry: 2, relax: true, ->
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
