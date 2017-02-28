
mecano = require '../../src'
test = require '../test'

describe 'registry.unregister', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'remove property', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.unregister 'my_function'
      mecano.registered('my_function').should.be.false()

    it 'work on already removed property', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.unregister 'my_function'
      mecano.unregister 'my_function'
      mecano.registered('my_function').should.be.false()

  describe 'local', ->

    it 'remove property', ->
      mecano()
      .registry.register 'my_function', -> 'my_function'
      .registry.unregister 'my_function'
      .registry.registered('my_function').should.be.false()

    it 'work on already removed property', ->
      m = mecano()
      m
      .registry.register 'my_function', -> 'my_function'
      .registry.unregister 'my_function'
      .registry.unregister 'my_function'
      .registry.registered('my_function').should.be.false()

  describe 'mixed', ->

    it.skip 'throw error if unregistering from local', (next) ->
      # we need to change the logic, it shall be ok to un-register
      mecano.register 'my_function', -> 'my_function'
      m = mecano()
      m.registry.registered('my_function').should.be.true()
      try
        m.registry.unregister 'my_function'
      catch e
        e.message.should.eql 'Unregister a global function from local context'
        mecano.unregister 'my_function'
        next()
