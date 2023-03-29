
{tags} = require '../test'
nikita = require '../../lib'
registry = require '../../lib/registry'

describe 'registry', ->
  return unless tags.api

  it 'statically', ->
    registry.register 'my_function', (->)
    registry.registered('my_function').should.be.true()
    registry.unregister 'my_function'
