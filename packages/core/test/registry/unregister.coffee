
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'registry.unregister', ->

  describe 'global', ->

    it 'remove property', ->
      nikita.registry.register 'my_function', -> 'my_function'
      nikita.registry.unregister 'my_function'
      nikita.registry.registered('my_function').should.be.false()

    it 'work on already removed property', ->
      nikita.registry.register 'my_function', -> 'my_function'
      nikita.registry.unregister 'my_function'
      nikita.registry.unregister 'my_function'
      nikita.registry.registered('my_function').should.be.false()

  describe 'local', ->

    it 'remove property', ->
      nikita()
      .registry.register 'my_function', -> 'my_function'
      .registry.unregister 'my_function'
      .registry.registered('my_function').should.be.false()

    it 'work on already removed property', ->
      m = nikita()
      m
      .registry.register 'my_function', -> 'my_function'
      .registry.unregister 'my_function'
      .registry.unregister 'my_function'
      .registry.registered('my_function').should.be.false()

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
