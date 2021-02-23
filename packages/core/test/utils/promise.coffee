
{tags} = require '../test'
promise = require '../../src/utils/promise'

describe 'utils.promise', ->
  return unless tags.api

  it 'true', ->
    promise.is(new Promise (->)).should.be.true()

  it 'false', ->
    promise.is({}).should.be.false()
