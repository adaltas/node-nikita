
nikita = require '../../src'
test = require '../test'

describe 'api events "end"', ->

  it 'provide a single log argument', (next) ->
    nikita()
    .on 'end', (log) ->
      console.log 'TODO: test log object', log
      next()
    .on 'error', (err) -> next err
    .call (_, callback) ->
      callback()

  it 'end is called after handler', (next) ->
    next_called = false
    nikita()
    .on 'end', ->
      next_called.should.be.true()
      next()
    .on 'error', (err) -> next err
    .call (_, callback) ->
      setImmediate ->
        callback()
        next_called = true

  it 'end is called after next', (next) ->
    next_called = false
    nikita()
    .on 'end', ->
      next_called.should.be.true()
      next()
    .on 'error', (err) -> next err
    .call (_, callback) ->
      setImmediate callback
    .next ->
      next_called = true
