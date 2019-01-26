
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "depth"', ->

  it 'start at 1', ->
    nikita
    .call ({options}) ->
      options.depth.should.eql 1
    .promise()

  it 'is incremented and decremented', ->
    nikita
    .call ->
      @call ({options}) ->
        options.depth.should.eql 2
        @call ({options}) ->
          options.depth.should.eql 3
          @call ({options}) ->
            options.depth.should.eql 4
      @call ({options}) ->
        options.depth.should.eql 2
        @call ({options}) ->
          options.depth.should.eql 3
    .promise()

  it 'set root level', ->
    nikita
    .call ->
      @call ({options}) ->
        options.depth.should.eql 2
        @call depth: 0, ({options}) ->
          options.depth.should.eql 0
          @call ({options}) ->
            options.depth.should.eql 1
    .call ->
      @call ({options}) ->
        options.depth.should.eql 2
        @call depth: 4, ({options}) ->
          options.depth.should.eql 4
          @call ({options}) ->
            options.depth.should.eql 5
            @call ({options}) ->
              options.depth.should.eql 6
    .promise()
