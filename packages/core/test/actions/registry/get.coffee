
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.registry.get', ->
  return unless test.tags.posix
  
  it 'all actions', ->
    actions = await nikita.registry.get()
    Object.keys(actions.registry).should.eql [
      'get'
      'register'
      'registered'
      'unregister'
    ]
  
  it 'single action', ->
    action = await nikita
      .registry.register(['an', 'action'], {
        handler: () => 'gotme'
      })
      .registry.get(['an', 'action'])
    action.handler().should.eql 'gotme'
        