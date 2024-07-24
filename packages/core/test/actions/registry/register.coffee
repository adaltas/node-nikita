
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.registry.register', ->
  return unless test.tags.posix

  it 'action', ->
    result = await nikita
      .registry.register
        namespace: ['an', 'action']
        action:
          handler: () => 'gotme'
      .an.action()
    result.should.eql 'gotme'

  it 'multiple actions', ->
    result = await nikita
      .registry.register
        actions:
          "an":
            "action": () => 'an action'
          "another":
            "action": () => 'another action'
      .an.action()
    result.should.eql 'an action'
        