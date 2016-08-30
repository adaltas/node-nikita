
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "before"', ->

  scratch = test.scratch @
  
  it 'is a function', (next) ->
    history = []
    mecano
    .call
      key: '1'
      before: (options) -> history.push "before #{options.key}"
      handler: (options) -> history.push "handler #{options.key}"
    .then (err) ->
      history.should.eql ['before 1', 'handler 1'] unless err
      next err
  
   it 'has custom options', (next) ->
     history = []
     mecano
     .call
       key: '1'
       before: key: 2, handler: (options) -> history.push "before #{options.key}"
       handler: (options) -> history.push "handler #{options.key}"
     .then (err) ->
       history.should.eql ['before 2', 'handler 1'] unless err
       next err
    
    it 'register child handlers', (next) ->
      history = []
      mecano
      .call
        key: 'parent'
        before: (options) ->
          history.push "before #{options.key}"
          @call key: 'child', (options) -> history.push "handler #{options.key}"
        handler: (options) -> history.push "handler #{options.key}"
      .then (err) ->
        history.should.eql ['before parent', 'handler child', 'handler parent'] unless err
        next err
