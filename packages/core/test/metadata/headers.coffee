
nikita = require '../../src'
test = require '../test'
{tags} = require '../test'

return unless tags.api

describe 'metadata "headers"', ->
  
  it 'default to []', ->
    nikita
    .call ({metadata}) ->
      metadata.headers.should.eql []
    .promise()
  
  it 'pass headers', ->
    nikita
    .call header: 'h 1', ({metadata}) ->
      metadata.headers.should.eql ['h 1']
      @call ->
        @call header: 'h 1.1', ({metadata}) ->
          metadata.headers.should.eql ['h 1', 'h 1.1']
        @call header: 'h 1.2', ({metadata}) ->
          metadata.headers.should.eql ['h 1', 'h 1.2']
    .call header: 'h 2', ({metadata}) ->
      metadata.headers.should.eql ['h 2']
      @call ->
        @call header: 'h 2.1', ({metadata}) ->
          metadata.headers.should.eql ['h 2', 'h 2.1']
    .promise()
  
  it 'get headers', ->
    nikita()
    .registry.register( 'my_action', header: 'default value', handler: ({metadata}) ->
      @call header: 'h 1.1.1', ({metadata, parent}) ->
        metadata.headers.should.eql ['h 1', parent.options.assert, 'h 1.1.1']
    )
    .call header: 'h 1', ->
      @my_action assert: 'default value'
      @my_action header: 'new header', assert: 'new header'
    .promise()
