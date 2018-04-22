
nikita = require '../../src'
test = require '../test'

describe 'api events', ->

  it 'end is called after handler', (next) ->
    calls = []
    nikita()
    .on 'end', ->
      calls.handler.should.be.true()
      next()
    .on 'error', (err) -> next err
    .call (_, callback) ->
      setImmediate ->
        callback()
        calls.handler = true

  it 'end is called after next', (next) ->
    calls = []
    nikita()
    .on 'end', ->
      calls.next.should.be.true()
      next()
    .on 'error', (err) -> next err
    .call (_, callback) ->
      setImmediate callback
    .next ->
      calls.next = true

  it.skip 'error', (next) ->
    end = error = false
    nikita()
    .on 'end', -> end = true
    .on 'error', (err) -> error = err
    .call -> throw Error 'KO'
    .call (callback) ->
      process.nextTick ->
        end.should.be.false()
        error.message.should.eql 'KO'
        callback()
    .promise()
