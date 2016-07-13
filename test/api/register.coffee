
mecano = require '../../src'
test = require '../test'

describe 'api register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'set property', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.registered('my_function').should.be.true()
      mecano.unregister 'my_function'

    it 'registering twice', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.register 'my_function', -> 'my_function'

    it 'is available from mecano instance', (next) ->
      mecano.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      m = mecano()
      m.registered('my_function').should.be.true()
      m.my_function
        my_option: 'my value'
      .then (err, status) ->
        status.should.be.true()
        mecano.unregister 'my_function'
        next err
    
    it 'namespace accept array', (next) ->
      value = null
      mecano.register ['this', 'is', 'a', 'function'], (options, callback) ->
        value = options.value
        callback null, true
      m = mecano()
      m.registered(['this', 'is', 'a', 'function']).should.be.true()
      m.this.is.a.function value: 'yes'
      m.then (err, status) ->
        status.should.be.true()
        mecano.unregister ['this', 'is', 'a', 'function']
        next err
        
    it 'namespace accept object', (next) ->
      value_a = value_b = null
      mecano.register 
        namespace:
          "": (options, callback) ->
            value_a = options.value
            callback null, true
          "child": (options, callback) ->
            value_b = options.value
            callback null, true
      mecano
      .call (_, next) ->
        mecano.namespace(value: 'a').then next
      .call (_, next) ->
        mecano.namespace.child(value: 'b').then next
      .then (err, status) ->
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        mecano.unregister "namespace"
        next err
    
    it 'namespace call function with children', (next) ->
      value_a = value_b = null
      mecano.register ['a', 'function'], (options, callback) ->
        value_a = options.value
        callback null, true
      mecano.register ['a', 'function', 'with', 'a', 'child'], (options, callback) ->
        value_b = options.value
        callback null, true
      mecano.registered(['a', 'function']).should.be.true()
      mecano
      .call (_, next) -> mecano.a.function(value: 'a').then next
      .call (_, next) -> mecano.a.function.with.a.child(value: 'b').then next
      .then (err, status) ->
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        mecano.unregister ['a', 'function']
        mecano.unregister ['a', 'function', 'with', 'a', 'child']
        next err

  describe 'local', ->

    it 'set property', ->
      m = mecano()
      m.register 'my_function', -> 'my_function'
      m.registered('my_function').should.be.true()
      m.unregister 'my_function'

    it 'receive options', (next) ->
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
          
    it 'support lazy validation for late registration', (next) ->
      name = null
      mecano
      .call ->
        @register 'my_function', (options) -> name = options.name
      .my_function name: 'callme'
      .then (err) ->
        name.should.eql 'callme' unless err
        next err
    
    it 'namespace accept array', (next) ->
      value = null
      mecano()
      .register ['this', 'is', 'a', 'function'], (options, callback) ->
        value = options.value
        callback null, true
      .this.is.a.function value: 'yes'
      .then (err, status) ->
        status.should.be.true()
        mecano.unregister ['this', 'is', 'a', 'function']
        next err
    
    it 'namespace accept object', (next) ->
      value_a = value_b = null
      mecano()
      .register 
        namespace:
          "": (options, callback) ->
            value_a = options.value
            callback null, true
          "child": (options, callback) ->
            value_b = options.value
            callback null, true
      .namespace value: 'a'
      .namespace.child value: 'b'
      .then (err, status) ->
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        next err
    
    it 'namespace call function with children', (next) ->
      value_a = value_b = null
      mecano()
      .register ['a', 'function'], (options, callback) ->
        value_a = options.value
        callback null, true
      .register ['a', 'function', 'with', 'a', 'child'], (options, callback) ->
        value_b = options.value
        callback null, true
      .a.function value: 'a'
      .a.function.with.a.child value: 'b'
      .then (err, status) ->
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        mecano.unregister ['a', 'function']
        mecano.unregister ['a', 'function', 'with', 'a', 'child']
        next err

  describe 'mixed', ->
    
    it 'support lazy validation for late registration', (next) ->
      name = null
      mecano
      .call ->
        mecano.register 'my_function', (options) -> name = options.name
      .my_function name: 'callme'
      .then (err) ->
        name.should.eql 'callme' unless err
        mecano.unregister 'my_function'
        next err
