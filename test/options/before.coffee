
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "before"', ->
  
  it 'is a function', ->
    history = []
    nikita
    .call
      key: '1'
      before: ({options}) -> history.push "before #{options.key}"
      handler: ({options}) -> history.push "handler #{options.key}"
    .next (err) ->
      history.should.eql ['before 1', 'handler 1'] unless err
    .promise()
  
   it 'has custom options',  ->
     history = []
     nikita
     .call
       key: '1'
       before: key: 2, handler: ({options}) -> history.push "before #{options.key}"
       handler: ({options}) -> history.push "handler #{options.key}"
     .next (err) ->
       history.should.eql ['before 2', 'handler 1'] unless err
     .promise()

    it 'register child handlers', ->
      history = []
      nikita
      .call
        key: 'parent'
        before: ({options}) ->
          history.push "before #{options.key}"
          @call key: 'child', ({options}) -> history.push "handler #{options.key}"
        handler: ({options}) -> history.push "handler #{options.key}"
      .next (err) ->
        history.should.eql ['before parent', 'handler child', 'handler parent'] unless err
      .promise()
