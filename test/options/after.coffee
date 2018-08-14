
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "after"', ->

  scratch = test.scratch @
  
  it 'is a function', ->
    history = []
    nikita
    .call
      key: '1'
      after: ({options}) -> history.push "after #{options.key}"
      handler: ({options}) -> history.push "handler #{options.key}"
    .call ->
      history.should.eql ['handler 1', 'after 1']
    .promise()
  
   it 'has custom options', ->
     history = []
     nikita
     .call
       key: '1'
       after: key: 2, handler: ({options}) -> history.push "after #{options.key}"
       handler: ({options}) -> history.push "handler #{options.key}"
     .call ->
       history.should.eql ['handler 1', 'after 2']
     .promise()

    it 'register child handlers', ->
      history = []
      nikita
      .call
        key: 'parent'
        after: ({options}) ->
          history.push "after #{options.key}"
          @call key: 'child', ({options}) -> history.push "handler #{options.key}"
        handler: ({options}) -> history.push "handler #{options.key}"
      .call ->
        history.should.eql ['handler parent', 'after parent', 'handler child']
      .promise()
