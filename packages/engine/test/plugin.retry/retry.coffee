
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "retry"', ->

  it 'handler thrown exception', ->
    nikita.call retry: 5, sleep: 100, ({metadata}) ->
      if metadata.attempt < 2
      then throw Error 'Catchme'
      else "success #{metadata.attempt}"
    .should.be.resolvedWith 'success 2'

  it 'handler rejected promises', ->
    nikita.call retry: 5, sleep: 100, ({metadata}) ->
      new Promise (resolve, reject) ->
        if metadata.attempt < 2
        then throw Error 'Catchme'
        else resolve "success #{metadata.attempt}"
    .should.be.resolvedWith 'success 2'

  it 'validate the number of retry', ->
    count = 0
    await nikita
    .call retry: 3, sleep: 100, ({metadata}) ->
      metadata.attempt.should.eql count++
      throw Error 'Catchme'
    .should.be.rejectedWith 'Catchme'
    count.should.eql 3

  it.skip 'retry x times log retry attempt', ->
    logs = []
    nikita
    .on 'text', (log) -> logs.push log.message if /^Retry/.test log.message
    .call retry: 2, sleep: 100, relax: true, ->
      throw Error 'Catchme'
    .call ->
      logs.should.eql ['Retry on error, attempt 1']

  it 'retry true is unlimited', ->
    nikita.call retry: true, sleep: 100, ({metadata}) ->
      if metadata.attempt < 10
      then throw Error "Catchme"
      else "success #{metadata.attempt}"
    .should.be.resolvedWith 'success 10'

  it 'ensure options are immutable between retry', ->
    nikita
    .call retry: 3, test: 1, sleep: 100, ({metadata, options}) ->
      options.test.should.eql 1
      options.test = 2
      throw Error 'Retry' if metadata.attempt < 2
