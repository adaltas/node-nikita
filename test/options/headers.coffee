
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "headers"', ->

  scratch = test.scratch @
  
  it 'default to []', ->
    nikita
    .call ({options}) ->
      options.headers.should.eql []
    .promise()
  
  it 'pass headers', ->
    nikita
    .call header: 'h 1', ({options}) ->
      options.headers.should.eql ['h 1']
      @call ->
        @call header: 'h 1.1', ({options}) ->
          options.headers.should.eql ['h 1', 'h 1.1']
        @call header: 'h 1.2', ({options}) ->
          options.headers.should.eql ['h 1', 'h 1.2']
    .call header: 'h 2', ({options}) ->
      options.headers.should.eql ['h 2']
      @call ->
        @call header: 'h 2.1', ({options}) ->
          options.headers.should.eql ['h 2', 'h 2.1']
    .promise()
  
  it 'get headers', ->
    nikita()
    .registry.register( 'my_action', header: 'default value', handler: ({options}) ->
      @call header: 'h 1.1.1', ({options}) ->
        options.headers.should.eql ['h 1', options.parent.assert, 'h 1.1.1']
    )
    .call header: 'h 1', ({options}) ->
      @my_action assert: 'default value'
      @my_action header: 'new header', assert: 'new header'
    .promise()
