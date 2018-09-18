
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "retry"', ->

  it 'stop once errorless', ->
    count = 0
    nikita
    .call retry: 5, sleep: 500, ({options}) ->
      options.attempt.should.eql count++
      throw Error 'Catchme' if options.attempt < 2
    .call ->
      count.should.eql 3
    .promise()

  it 'retry x times', ->
    count = 0
    nikita
    .call retry: 3, sleep: 100, ({options}) ->
      options.attempt.should.eql count++
      throw Error 'Catchme'
    .next (err) ->
      err.message.should.eql 'Catchme'
      count.should.eql 3
    .promise()

  it 'retry x times log retry attempt', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log.message if /^Retry/.test log.message
    .call retry: 2, sleep: 500, relax: true, ->
      throw Error 'Catchme'
    .call ->
      logs.should.eql ['Retry on error, attempt 1']
    .promise()

  it 'retry true is unlimited', ->
    count = 0
    nikita
    .call retry: true, sleep: 200, ->
      throw Error 'Catchme' if count++ < 10
    .promise()
