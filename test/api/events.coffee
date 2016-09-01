
mecano = require '../../src'
test = require '../test'

describe 'api events', ->

  it.skip 'end', (next) ->
    end = error = false
    mecano()
    .on 'end', -> end = true
    .on 'error', (err) -> error = err
    .then ->
      process.nextTick ->
        end.should.be.true()
        error.should.be.false()
        next()

  it.skip 'error', (next) ->
    end = error = false
    mecano()
    .on 'end', -> end = true
    .on 'error', (err) -> error = err
    .call -> throw Error 'KO'
    .then (err) ->
      process.nextTick ->
        end.should.be.false()
        error.message.should.eql 'KO'
        next()
      
