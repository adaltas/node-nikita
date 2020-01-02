
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "header"', ->
  
  it 'print value', ->
    headers = []
    nikita
    .on 'header', (log) ->
      headers.push message: log.message, headers: log.metadata.headers, depth: log.depth
    .call header: '1', ->
      @call header: '1.1', ->
        @call header: '1.1.1', (->)
      @call header: '1.2', (->)
    .call
      header: '2'
    , (->)
    .call ->
      headers.should.eql [
        { message: '1', headers: ['1'], depth: 1 }
        { message: '1.1', headers: ['1', '1.1'], depth: 2 }
        { message: '1.1.1', headers: ['1', '1.1', '1.1.1'], depth: 3 }
        { message: '1.2', headers: ['1', '1.2'], depth: 2 }
        { message: '2', headers: ['2'], depth: 1 }
      ]
    .promise()
