
import nikita from '@nikitajs/core'
import test from '../test.coffee'

describe 'registry.unregister', ->
  return unless test.tags.api

  describe 'local', ->

    it 'remove property', ->
      nikita
      .registry.register
        namespace: 'my_function'
        action:
          handler: (->)
      .registry.unregister
        namespace: 'my_function'
      .registry.registered
        namespace: 'my_function'
      .should.be.finally.false()

    it 'work on already removed property', ->
      nikita
      .registry.registered
        namespace: 'my_function'
        action:
          handler: (->)
      .registry.unregister
        namespace: 'my_function'
      .registry.unregister
        namespace: 'my_function'
      .registry.registered
        namespace: 'my_function'
      .should.be.finally.false()

  describe 'mixed', ->

    it.skip 'throw error if unregistering from local', (next) ->
      # we need to change the logic, it shall be ok to un-register
      nikita.registry.register 'my_function', -> 'my_function'
      m = nikita()
      m.registry.registered('my_function').should.be.true()
      try
        m.registry.unregister 'my_function'
      catch e
        e.message.should.eql 'Unregister a global function from local session'
        nikita.registry.unregister 'my_function'
        next()
