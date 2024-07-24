
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.registry.registered', ->
  return unless test.tags.posix

  it 'is registered', ->
    registered = await nikita
      .registry.register
        namespace: ['an', 'action']
        action:
          handler: () => 'gotme'
      .registry.registered
        namespace: ['an', 'action']
    registered.should.be.true()

  it 'is not registered', ->
    registered = await nikita
      .registry.registered
        namespace: ['an', 'action']
    registered.should.be.false()
        