
nikita = require '../../src'

describe 'registry.register', ->

  describe 'global', ->

    it 'set property', ->
      nikita.registry.register 'my_function', -> 'my_function'
      nikita.registry.registered('my_function').should.be.true()
      nikita.registry.unregister 'my_function'

    it 'register twice', ->
      nikita.registry.register 'my_function', -> 'my_function'
      nikita.registry.register 'my_function', -> 'my_function'

    it 'register an object with options', ->
      value_a = value_b = null
      nikita.registry.register 'my_function', shy: true, handler: (options) ->
        value_a = "hello #{options.value}"
      nikita.registry.register 'my': 'function': shy: true, handler: (options, callback) ->
        value_b = "hello #{options.value}"
        callback null, true
      nikita
      .call (_, callback) ->
        nikita
        .my_function value: 'world'
        .next (err, {status}) ->
          status.should.be.false() unless err
          callback err
      .call (_, callback) ->
        nikita
        .my.function value: 'world'
        .next (err, {status}) ->
          status.should.be.false() unless err
          callback err
      .call ->
        value_a.should.eql "hello world"
        value_b.should.eql "hello world"
        nikita.registry.unregister 'my_function'
        nikita.registry.unregister ['my', 'function']
      .promise()

    it 'overwrite middleware options', ->
      value_a = value_b = null
      nikita.registry.register 'my_function', key: 'a', handler: (->)
      nikita.registry.register 'my_function', key: 'b', handler: (options) -> value_a = "Got #{options.key}"
      nikita.registry.register
        'my': 'function': key: 'a', handler: (->)
      nikita.registry.register
        'my': 'function': key: 'b', handler: (options) ->
          value_b = "Got #{options.key}"
      nikita()
      .call (_, callback) ->
        nikita.my_function callback
      .call (_, callback) ->
        nikita.my.function callback
      .call ->
        value_a.should.eql "Got b"
        value_b.should.eql "Got b"
        nikita.registry.unregister 'my_function'
        nikita.registry.unregister ['my', 'function']
      .promise()

    it 'is available from nikita instance', ->
      nikita.registry.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      n = nikita()
      n.registry.registered('my_function').should.be.true()
      n.my_function
        my_option: 'my value'
      n.next (err, {status}) ->
        throw err if err
        status.should.be.true()
        nikita.registry.unregister 'my_function'
      n.promise()

    it 'namespace accept array', ->
      value = null
      nikita.registry.register ['this', 'is', 'a', 'function'], (options, callback) ->
        value = options.value
        callback null, true
      n = nikita()
      n.registry.registered(['this', 'is', 'a', 'function']).should.be.true()
      n.this.is.a.function value: 'yes'
      n.next (err, {status}) ->
        throw err if err
        status.should.be.true()
        nikita.registry.unregister ['this', 'is', 'a', 'function']
      n.promise()

    it 'namespace accept object', ->
      value_a = value_b = null
      nikita.registry.register
        namespace:
          "": (options, callback) ->
            value_a = options.value
            callback null, true
          "child": (options, callback) ->
            value_b = options.value
            callback null, true
      nikita
      .call (_, next) ->
        nikita.namespace(value: 'a').next next
      .call (_, next) ->
        nikita.namespace.child(value: 'b').next next
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        nikita.registry.unregister "namespace"
      .promise()

    it 'namespace call function with children', ->
      value_a = value_b = null
      nikita.registry.register ['a', 'function'], (options, callback) ->
        value_a = options.value
        callback null, true
      nikita.registry.register ['a', 'function', 'with', 'a', 'child'], (options, callback) ->
        value_b = options.value
        callback null, true
      nikita.registry.registered(['a', 'function']).should.be.true()
      nikita
      .call (_, callback) -> nikita.a.function(value: 'a').next callback
      .call (_, callback) -> nikita.a.function.with.a.child(value: 'b').next callback
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
        nikita.registry.unregister ['a', 'function']
        nikita.registry.unregister ['a', 'function', 'with', 'a', 'child']
      .promise()

    it 'throw error unless registered', ->
      (->
        nikita.invalid()
      ).should.throw 'nikita.invalid is not a function'
      nikita.registry.register ['ok', 'and', 'valid'], (->)
      (->
        nikita.ok.and.invalid()
      ).should.throw 'nikita.ok.and.invalid is not a function'
      nikita.registry.unregister ['ok', 'and', 'valid']

  describe 'local', ->

    it 'set property', ->
      n = nikita()
      n.registry.register 'my_function', -> 'my_function'
      n.registry.registered('my_function').should.be.true()
      n.registry.unregister 'my_function'
      .promise()

    it 'overwrite a middleware', ->
      nikita()
      .registry.register 'my_function', -> 'my_function'
      .registry.register 'my_function', -> 'my_function'
      .promise()

    it 'register an object with options', ->
      value_a = value_b = null
      nikita()
      .registry.register( 'my_function', shy: true, handler: (options, callback) ->
        value_a = "hello #{options.value}"
        callback null, true
      )
      .registry.register
        'my': 'function': shy: true, handler: (options, callback) ->
          value_b = "hello #{options.value}"
          callback null, true
      .my_function value: 'world a'
      .my.function value: 'world b'
      .next (err, {status}) ->
        throw err if err
        status.should.be.false()
        value_a.should.eql "hello world a"
        value_b.should.eql "hello world b"
      .promise()

    it 'overwrite middleware options', ->
      value_a = value_b = null
      nikita()
      .registry.register( 'my_function', key: 'a', handler: (->) )
      .registry.register( 'my_function', key: 'b', handler: (options) -> value_a = "Got #{options.key}" )
      .registry.register
        'my': 'function': key: 'a', handler: (->)
      .registry.register
        'my': 'function': key: 'b', handler: (options) -> value_b = "Got #{options.key}"
      .my_function()
      .my.function()
      .call ->
        value_a.should.eql "Got b"
        value_b.should.eql "Got b"
      .promise()

    it 'receive options', ->
      n = nikita()
      .registry.register 'my_function', (options, callback) ->
        options.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      .my_function
        my_option: 'my value'
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
        n.registry.registered('my_function').should.be.true()
      n.promise()

    it 'register module name', ->
      logs = []
      n = nikita()
      .on 'text', (l) -> logs.push l.message
      .registry.register 'module_sync', 'test/resources/module_sync'
      .registry.register 'module_async', 'test/resources/module_async'
      .module_sync who: 'sync'
      .module_async who: 'async'
      .call ->
        n.registry.registered('module_sync').should.be.true()
        n.registry.registered('module_async').should.be.true()
        logs.should.eql ['Hello sync', 'Hello async']
      n.promise()

    it 'namespace accept array', ->
      value = null
      nikita()
      .registry.register ['this', 'is', 'a', 'function'], (options, callback) ->
        value = options.value
        callback null, true
      .this.is.a.function value: 'yes'
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
      .promise()

    it 'namespace accept object', ->
      value_a = value_b = null
      nikita()
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
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
      .promise()

    it 'namespace call function with children', ->
      value_a = value_b = null
      nikita()
      .registry.register ['a', 'function'], (options, callback) ->
        value_a = options.value
        callback null, true
      .registry.register ['a', 'function', 'with', 'a', 'child'], (options, callback) ->
        value_b = options.value
        callback null, true
      .a.function value: 'a'
      .a.function.with.a.child value: 'b'
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
        value_a.should.eql 'a'
        value_b.should.eql 'b'
      .promise()

    it 'throw error unless registered', ->
      (->
        nikita().invalid()
      ).should.throw 'nikita(...).invalid is not a function'
      (->
        n = nikita()
        n.registry.register ['ok', 'and', 'valid'], (->)
        n.ok.and.invalid()
      ).should.throw 'n.ok.and.invalid is not a function'
