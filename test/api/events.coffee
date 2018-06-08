
nikita = require '../../src'
test = require '../test'

describe 'api events', ->

  it 'error', (next) ->
    error_called = false
    nikita()
    .on 'end', ->
      next Error 'Not here'
    .on 'error', (err) ->
      error_called.should.be.true()
      err.message.should.eql 'Get me'
      next()
    .call (_, callback) ->
      process.nextTick ->
        error_called = true
        callback Error 'Get me'
    .call -> throw Error 'KO'
    null
