
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "retry"', ->

  it 'stop once errorless', ->
    count = 0
    nikita
    .call retry: 5, sleep: 100, ({metadata}) ->
      metadata.attempt.should.eql count++
      throw Error 'Catchme' if metadata.attempt < 2
    .call ->
      count.should.eql 3
    .promise()

  it 'retry x times', ->
    count = 0
    nikita
    .call retry: 3, sleep: 100, ({metadata}) ->
      metadata.attempt.should.eql count++
      throw Error 'Catchme'
    .next (err) ->
      err.message.should.eql 'Catchme'
      count.should.eql 3
    .promise()

  it 'retry x times log retry attempt', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log.message if /^Retry/.test log.message
    .call retry: 2, sleep: 100, relax: true, ->
      throw Error 'Catchme'
    .call ->
      logs.should.eql ['Retry on error, attempt 1']
    .promise()

  it 'retry true is unlimited', ->
    count = 0
    nikita
    .call retry: true, sleep: 100, ->
      throw Error 'Catchme' if count++ < 10
    .promise()

  it 'ensure options are immutable between retry', ->
    nikita
    .call retry: 2, test: 1, sleep: 100, ({metadata, options}) ->
      options.test.should.eql 1
      options.test = 2
      throw Error 'Retry' if metadata.attempt is 0
    .promise()
