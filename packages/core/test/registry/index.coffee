
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry', ->

  it 'statically', ->
    registry.register 'my_function', (->)
    registry.registered('my_function').should.be.true()
    registry.unregister 'my_function'
