
nikita = require '../../src'
test = require '../test'

describe 'api events', ->

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

  it 'error', (next) ->
    error_called = false
    nikita()
    .on 'end', -> next Error 'Not here'
    .on 'error', (err) ->
      error_called.should.be.true()
      err.message.should.eql 'Get me'
      next()
    .call (_, callback) ->
      process.nextTick ->
        error_called = true
        callback Error 'Get me'
    .call -> throw Error 'KO'
