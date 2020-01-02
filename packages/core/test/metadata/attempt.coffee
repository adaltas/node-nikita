
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "attempt"', ->

  it 'start with value 0', ->
    count = 0
    nikita
    .call ({metadata}) ->
      metadata.attempt.should.eql 0
    .promise()

  it 'follow the number of retry', ->
    count = 0
    nikita
    .call retry: 5, sleep: 0, ({metadata}) ->
      metadata.attempt.should.eql count++
      throw Error 'Catchme' if metadata.attempt < 4
    .promise()

  it 'reschedule attempt with relax', ->
    count = 0
    nikita
    .call retry: 3, relax: true, sleep: 0, ({metadata}) ->
      metadata.attempt.should.eql count++
      throw Error 'Catchme'
    .call ->
      count.should.eql 3
    .promise()
