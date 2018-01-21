
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api status', ->

  it 'store is an object', ->
    nikita
    .call ->
      @store.should.be.an.Object()
    .promise()
