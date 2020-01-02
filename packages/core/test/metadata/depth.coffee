
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "depth"', ->

  it 'start at 1', ->
    nikita
    .call ({metadata}) ->
      metadata.depth.should.eql 1
    .promise()

  it 'is incremented and decremented', ->
    nikita
    .call ->
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call ({metadata}) ->
          metadata.depth.should.eql 3
          @call ({metadata}) ->
            metadata.depth.should.eql 4
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call ({metadata}) ->
          metadata.depth.should.eql 3
    .promise()

  it 'set root level', ->
    nikita
    .call ->
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call depth: 0, ({metadata}) ->
          metadata.depth.should.eql 0
          @call ({metadata}) ->
            metadata.depth.should.eql 1
    .call ->
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call depth: 4, ({metadata}) ->
          metadata.depth.should.eql 4
          @call ({metadata}) ->
            metadata.depth.should.eql 5
            @call ({metadata}) ->
              metadata.depth.should.eql 6
    .promise()
