
mecano = require '../../src'
test = require '../test'

describe 'api register', ->

  scratch = test.scratch @

  describe 'global', ->

    it 'set property', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.registered('my_function').should.be.true()
      mecano.unregister 'my_function'

    it 'register twice', ->
      mecano.register 'my_function', -> 'my_function'
      mecano.register 'my_function', -> 'my_function'

    it 'register an object', ->
      mecano.register 'my_function', shy: true, handler: (options) -> "hello #{options.value}"
      mecano.register
        'my': 'function': shy: true, handler: (options, callback) ->
          value = "hello #{options.value}"
          callback null, true
      mecano.my_function value: 'world'
      mecano.my.function value: 'world'
      mecano.unregister 'my_function'
      mecano.unregister ['my', 'function']

    it 'is available from mecano instance', (next) ->
      mecano.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      m = mecano()
      m.registry.registered('my_function').should.be.true()
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
      m.registry.registered(['this', 'is', 'a', 'function']).should.be.true()
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

    it 'throw error unless registered', (next) ->
      mecano
      .invalid()
      .then (err) ->
        err.message.should.eql 'Unregistered Handler: invalid'
        next()

  describe 'local', ->

    it 'set property', ->
      m = mecano()
      m.registry.register 'my_function', -> 'my_function'
      m.registry.registered('my_function').should.be.true()
      m.registry.unregister 'my_function'

    it 'register twice', ->
      mecano()
      .registry.register 'my_function', -> 'my_function'
      .registry.register 'my_function', -> 'my_function'

    it 'register an object', (next) ->
      value_a = value_b = null
      mecano()
      .registry.register 'my_function', (options) -> value_a = "hello #{options.value}"
      .registry.register
        'my': 'function': shy: true, handler: (options, callback) ->
          value_b = "hello #{options.value}"
          callback null, true
      .my_function value: 'world a'
      .my.function value: 'world b'
      .then (err, status) ->
        status.should.be.false() unless err
        value_a.should.eql "hello world a" unless err
        value_b.should.eql "hello world b" unless err
        next err

    it 'receive options', (next) ->
      m = mecano()
      .registry.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      .my_function
        my_option: 'my value'
      .then (err, modified) ->
        modified.should.be.true()
        m.registry.registered('my_function').should.be.true()
        next err

    it 'register module name', (next) ->
      logs = []
      m = mecano()
      .on 'text', (l) -> logs.push l.message
      .registry.register 'module_sync', 'test/resources/module_sync'
      .registry.register 'module_async', 'test/resources/module_async'
      .module_sync who: 'sync'
      .module_async who: 'async'
      .then (err, modified) ->
        m.registry.registered('module_sync').should.be.true() unless err
        m.registry.registered('module_async').should.be.true() unless err
        logs.should.eql ['Hello sync', 'Hello async'] unless err
        next err

    it 'support lazy validation for late registration', (next) ->
      name = null
      mecano
      .call ->
        @registry.register ['my', 'function'], (options) -> name = options.name
      .my.function name: 'callme'
      .then (err) ->
        name.should.eql 'callme' unless err
        next err

    it 'namespace accept array', (next) ->
      value = null
      mecano()
      .registry.register ['this', 'is', 'a', 'function'], (options, callback) ->
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
      .registry.register
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
      .registry.register ['a', 'function'], (options, callback) ->
        value_a = options.value
        callback null, true
      .registry.register ['a', 'function', 'with', 'a', 'child'], (options, callback) ->
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

    it 'throw error unless registered', (next) ->
      mecano()
      .invalid()
      .then (err) ->
        err.message.should.eql 'Unregistered Handler: invalid'
        next()

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
