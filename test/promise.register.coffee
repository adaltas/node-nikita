
mecano = require '../src'
test = require './test'

describe 'promise register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'and un-register', ->
      mecano
      .register 'my_function', -> 'my_function'
      .registered('my_function').should.be.True
      # Unregister
      mecano
      .register 'my_function', null
      .registered('my_function').should.be.False
      # Unregister an unregistered
      mecano
      .register 'my_function', null
      .registered('my_function').should.be.False

    it 'throw error if registering twice', (next) ->
      mecano.register 'my_function', -> 'my_function'
      try
        mecano.register 'my_function', -> 'my_function'
      catch e
        mecano.register 'my_function', null
        e.message.should.eql 'Function already defined \'my_function\''
        next()

    it 'throw error if unregistering from local', ->
      mecano.register 'my_function', -> 'my_function'
      m = mecano()
      m.registered('my_function').should.be.True
      try
        m.register 'my_function', null
      catch e
        e.message.should.eql 'Unregister a global function from local context'
        mecano.register 'my_function', null

    it 'is available from mecano instance', ->
      mecano.register 'my_function', -> 'my_function'
      mecano()
      .registered('my_function').should.be.True
      mecano.register 'my_function', null

  describe 'local', ->

    it 'and un-register', ->
      m = mecano()
      m
      .register 'my_function', -> 'my_function'
      .registered('my_function').should.be.True
      # Unregister
      m
      .register 'my_function', null
      .registered('my_function').should.be.False
      # Unregister an unregistered
      m
      .register 'my_function', null
      .registered('my_function').should.be.False

