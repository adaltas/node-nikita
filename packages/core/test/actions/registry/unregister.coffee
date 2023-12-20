
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.registry.unregister', ->
  return unless test.tags.posix

  it 'was never registered', ->
    registered = await nikita
      .registry.registered(['an', 'action'])
    registered.should.be.false()

  it 'is no longer registered', ->
    registered = await nikita
      .registry.register(['an', 'action'], {
        handler: () => 'gotme'
      })
      .registry.unregister(['an', 'action'], {
        handler: () => 'gotme'
      })
      .registry.registered(['an', 'action'])
    registered.should.be.false()
        