
import nikita from '@nikitajs/core'
import registry from '@nikitajs/core/registry'
import test from '../test.coffee'

describe 'registry', ->
  return unless test.tags.api

  it 'statically', ->
    registry.register 'my_function', (->)
    registry.registered('my_function').should.be.true()
    registry.unregister 'my_function'
