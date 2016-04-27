
mecano = require '../../src'
test = require '../test'

describe 'api register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'and un-register', ->
      mecano
      .register 'my_function', -> 'my_function'
      .registered('my_function').should.be.true()
      # Unregister
      mecano
      .register 'my_function', null
      .registered('my_function').should.be.false()
      # Unregister an unregistered
      mecano
      .register 'my_function', null
      .registered('my_function').should.be.false()

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
      m.registered('my_function').should.be.true()
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
      m.registered('my_function').should.be.true()
      m.my_function
        my_option: 'my value'
      .then (err, modified) ->
        modified.should.be.true()
        mecano.register 'my_function', null
        next err

  describe 'local', ->

    it 'and un-register', ->
      m = mecano()
      m
      .register 'my_function', -> 'my_function'
      .registered('my_function').should.be.true()
      # Unregister
      m
      .register 'my_function', null
      .registered('my_function').should.be.false()
      # Unregister an unregistered
      m
      .register 'my_function', null
      .registered('my_function').should.be.false()

    it 'call', (next) ->
      m = mecano()
      .register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      .my_function
        my_option: 'my value'
      .then (err, modified) ->
        modified.should.be.true()
        m.registered('my_function').should.be.true()
        next err
    
    it 'register module name', (next) ->
      logs = []
      m = mecano()
      .on 'text', (l) -> logs.push l.message
      .register 'module_sync', 'test/resources/module_sync'
      .register 'module_async', 'test/resources/module_async'
      .module_sync who: 'sync'
      .module_async who: 'async'
      .then (err, modified) ->
        m.registered('module_sync').should.be.true() unless err
        m.registered('module_async').should.be.true() unless err
        logs.should.eql ['Hello sync', 'Hello async'] unless err
        next err
    
    it.skip 'support lazy validation for late registration', (next) ->
      # This test could only be supported with dynamic method call, probably
      # once we introduce a proxy implementation. At the moment, the call
      # to "my_function" throw a TypeError complaining that the function does
      # not exists.
      name = null
      mecano
      .call ->
        @register 'my_function', (options) -> name = options.name
      .my_function name: 'callme'
      .then (err) ->
        name.should.eql 'callme' unless err
        next err
