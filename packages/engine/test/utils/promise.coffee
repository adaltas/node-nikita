
promise = require '../../src/utils/promise'

describe 'utils.promise', ->

  it 'true', ->
    promise.is(new Promise (->)).should.be.true()

  it 'false', ->
    promise.is({}).should.be.false()
