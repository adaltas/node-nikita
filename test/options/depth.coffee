
nikita = require '../../src'

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
