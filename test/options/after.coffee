
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "after"', ->

  scratch = test.scratch @
  
  it 'is a function', (next) ->
    history = []
    nikita
    .call
      key: '1'
      after: (options) -> history.push "after #{options.key}"
      handler: (options) -> history.push "handler #{options.key}"
    .then (err) ->
      history.should.eql ['handler 1', 'after 1'] unless err
      next err
  
   it 'has custom options', (next) ->
     history = []
     nikita
     .call
       key: '1'
       after: key: 2, handler: (options) -> history.push "after #{options.key}"
       handler: (options) -> history.push "handler #{options.key}"
     .then (err) ->
       history.should.eql ['handler 1', 'after 2'] unless err
       next err
    
    it 'register child handlers', (next) ->
      history = []
      nikita
      .call
        key: 'parent'
        after: (options) ->
          history.push "after #{options.key}"
          @call key: 'child', (options) -> history.push "handler #{options.key}"
        handler: (options) -> history.push "handler #{options.key}"
      .then (err) ->
        history.should.eql ['handler parent', 'after parent', 'handler child'] unless err
        next err
