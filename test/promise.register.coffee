
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

    it.skip 'throw error if unregistering from local', (next) ->
      # we need to change the logic, it shall be ok to un-register
      mecano.register 'my_function', -> 'my_function'
      m = mecano()
      m.registered('my_function').should.be.True
      try
        m.register 'my_function', null
      catch e
        e.message.should.eql 'Unregister a global function from local context'
        mecano.register 'my_function', null
        next()

    it 'is available from mecano instance', (next) ->
      mecano.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      m = mecano()
      m.registered('my_function').should.be.True
      m.my_function
        my_option: 'my value'
      .then (err, modified) ->
        modified.should.be.True
        mecano.register 'my_function', null
        next err

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

    it 'call', (next) ->
      m = mecano()
      .register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      .my_function
        my_option: 'my value'
      .then (err, modified) ->
        modified.should.be.True
        m.registered('my_function').should.be.True
        next err

