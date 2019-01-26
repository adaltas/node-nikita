
nikita = require '../../src'
{tags} = require '../test'
  
return unless tags.api

describe 'api status', ->

  it 'store is an object', ->
    nikita
    .call ->
      @store.should.be.an.Object()
    .promise()
