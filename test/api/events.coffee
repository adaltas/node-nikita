
nikita = require '../../src'
test = require '../test'

describe 'api events', ->

  it.skip 'end', ->
    end = error = false
    nikita()
    .on 'end', -> end = true
    .on 'error', (err) -> error = err
    .call (callback) ->
      process.nextTick ->
        end.should.be.true()
        error.should.be.false()
        callback()
    .promise()

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
