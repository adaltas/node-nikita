
nikita = require '../../../src'
{tags} = require '../../test'
  
return unless tags.api

describe 'api events "handled"', ->

  it 'provides a single log argument', ->
    nikita()
    .on 'handled', (log) ->
      arguments.length.should.eql 1
      Object.keys(log).sort().should.eql [
        'depth', 'error', 'file', 'headers',
        'index', 'level', 'line', 'module',
        'shy', 'status', 'time', 'type'
      ]
    .call (_, callback) ->
      callback()
    .promise()

  it 'is called when action is finished', ->
    history = []
    nikita()
    .on 'handled', ->
      history.push 'event handled'
    .call ->
      history.push 'action 1 handler'
    , ->
      history.push 'action 1 callback'
    .call ->
      history.push 'action 2 handler'
    , ->
      history.push 'action 2 callback'
    .next ->
      history.should.eql [
        'action 1 handler',
        'event handled',
        'action 1 callback',
        'action 2 handler',
        'event handled',
        'action 2 callback' 
      ]
    .promise()
