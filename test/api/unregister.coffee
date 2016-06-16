
mecano = require '../../src'
test = require '../test'

describe 'api unregister', ->

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

    it 'alias register without an handler', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.register 'my_function', null
      mecano.registered('my_function').should.be.false()

  describe 'local', ->

    it 'remove property', ->
      mecano()
      .register 'my_function', -> 'my_function'
      .unregister 'my_function'
      .registered('my_function').should.be.false()

    it 'work on already removed property', ->
      m = mecano()
      m
      .register 'my_function', -> 'my_function'
      .unregister 'my_function'
      .unregister 'my_function'
      .registered('my_function').should.be.false()

    it 'alias register without an handler', ->
      mecano()
      .register 'my_function', -> 'my_function'
      .register 'my_function', null
      .registered('my_function').should.be.false()

  describe 'mixed', ->

    it.skip 'throw error if unregistering from local', (next) ->
      # we need to change the logic, it shall be ok to un-register
      mecano.register 'my_function', -> 'my_function'
      m = mecano()
      m.registered('my_function').should.be.true()
      try
        m.unregister 'my_function'
      catch e
        e.message.should.eql 'Unregister a global function from local context'
        mecano.unregister 'my_function'
        next()
