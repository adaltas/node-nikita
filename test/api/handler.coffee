
nikita = require '../../src'
test = require '../test'

describe 'api handler', ->

  it.skip 'end', ->
    # CoffeeScript bug #4616
    # Test is disabled unti it's fixed
    n = nikita()
    .call header: 'h1', handler: (->)
    .call header: 'h2', handler: (->)
    .promise()
