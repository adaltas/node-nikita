
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.register', ->

  describe 'global', ->

    it 'register an action', ->
      reg = registry.create()
      reg.register 'my_function', (->)
      reg.registered('my_function').should.be.true()
      reg.unregister 'my_function'

    it 'overwrite an existing action', ->
      reg = registry.create()
      reg.register 'my_function', key: 1, handler: -> 'my_function'
      reg.register 'my_function', key: 2, handler: -> 'my_function'
      reg
      .get 'my_function'
      .key.should.eql 2

    it.skip 'call a function', ->
      console.log '-----'
      nikita
      .call ->
        nikita.registry.register 'my_function', ({options}) ->
          a_key: options.a_key
      .call ->
        # nikita
        # .my_function a_key: 'a value', (err, {a_key}) ->
        #   a_key.should.eql 'a value'
      .call ->
        nikita.registry.unregister 'my_function'

    it.skip 'register an object', ->
      value_a = value_b = null
      nikita.registry.register 'my_function', shy: true, handler: (->)
      nikita.registry.register 'my': 'function': shy: true, handler: (->)
      nikita.registry.registered('my_function').should.be.true()
      nikita.registry.registered(['my', 'function']).should.be.true()
      nikita.registry.unregister 'my_function'
      nikita.registry.unregister ['my', 'function']

    it.skip 'register an object with options', ->
      value_a = value_b = null
      nikita.registry.register 'my_function', shy: true, handler: ({options}) ->
        value_a = "hello #{options.value}"
      nikita.registry.register 'my': 'function': shy: true, handler: ({options}, callback) ->
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

    it.skip 'overwrite middleware options', ->
      value_a = value_b = null
      nikita.registry.register 'my_function', key: 'a', handler: (->)
      nikita.registry.register 'my_function', key: 'b', handler: ({options}) -> value_a = "Got #{options.key}"
      nikita.registry.register
        'my': 'function': key: 'a', handler: (->)
      nikita.registry.register
        'my': 'function': key: 'b', handler: ({options}) ->
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

    it.skip 'namespace accept array', ->
      value = null
      nikita.registry.register ['this', 'is', 'a', 'function'], ({options}, callback) ->
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

    it.skip 'namespace accept object', ->
      value_a = value_b = null
      nikita.registry.register
        namespace:
          "": ({options}, callback) ->
            value_a = options.value
            callback null, true
          "child": ({options}, callback) ->
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

    it.skip 'namespace call function with children', ->
      value_a = value_b = null
      nikita.registry.register ['a', 'function'], ({options}, callback) ->
        value_a = options.value
        callback null, true
      nikita.registry.register ['a', 'function', 'with', 'a', 'child'], ({options}, callback) ->
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

    it.skip 'throw error unless registered', ->
      (->
        nikita.invalid()
      ).should.throw 'nikita.invalid is not a function'
      nikita.registry.register ['ok', 'and', 'valid'], (->)
      (->
        nikita.ok.and.invalid()
      ).should.throw 'nikita.ok.and.invalid is not a function'
      nikita.registry.unregister ['ok', 'and', 'valid']

  describe 'local', ->

    it.skip 'register a function', ->
      n = nikita()
      n.registry.register 'my_function', (->)
      n.registry.registered('my_function').should.be.true()

    it.skip 'call a function', ->
      nikita()
      .registry.register 'my_function', ({options}, callback) -> callback null, a_key: options.a_key
      .my_function a_key: 'a value', (err, {a_key}) ->
        a_key.should.eql 'a value'
      .promise()

    it.skip 'overwrite a middleware', ->
      nikita()
      .registry.register 'my_function', -> 'my_function'
      .registry.register 'my_function', -> 'my_function'
      .promise()

    it.skip 'register an object', ->
      value_a = value_b = null
      n = nikita()
      n.registry.register 'my_function', shy: true, handler: (->)
      n.registry.register  'my': 'function': shy: true, handler: (->)
      n.registry.registered('my_function').should.be.true()
      n.registry.registered(['my', 'function']).should.be.true()
      n.promise()

    it.skip 'call an object', ->
      nikita()
      .registry.register( 'my_function', shy: true, handler: ({options}, callback) ->
        callback null, a_key: options.a_key
      )
      .registry.register( 'my': 'function': shy: true, handler: ({options}, callback) ->
        callback null, a_key: options.a_key
      )
      .my_function a_key: 'a value', (err, {a_key}) ->
        a_key.should.eql 'a value'
      .my.function a_key: 'a value', (err, {a_key}) ->
        a_key.should.eql 'a value'
      .promise()

    it.skip 'overwrite middleware options', ->
      value_a = value_b = null
      nikita()
      .registry.register( 'my_function', key: 'a', handler: (->) )
      .registry.register( 'my_function', key: 'b', handler: ({options}) -> value_a = "Got #{options.key}" )
      .registry.register
        'my': 'function': key: 'a', handler: (->)
      .registry.register
        'my': 'function': key: 'b', handler: ({options}) -> value_b = "Got #{options.key}"
      .my_function()
      .my.function()
      .call ->
        value_a.should.eql "Got b"
        value_b.should.eql "Got b"
      .promise()

    it.skip 'receive options', ->
      n = nikita()
      .registry.register 'my_function', ({options}, callback) ->
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

    it.skip 'register module name', ->
      logs = []
      n = nikita()
      .on 'text', (l) -> logs.push l.message if /^Hello/.test l.message
      .file
        target: "#{scratch}/module_sync.coffee"
        content: """
        module.exports = ({options}) ->
          @log "Hello \#{options.who or 'world'}"
        """
      .file
        target: "#{scratch}/module_async.coffee"
        content: """
        module.exports = ({options}, callback) ->
          setImmediate =>
            @log "Hello \#{options.who or 'world'}"
            callback null, true
        """
      .call ->
        @registry.register 'module_sync', "#{scratch}/module_sync.coffee"
        @registry.register 'module_async', "#{scratch}/module_async.coffee"
      .call ->
        @module_sync who: 'sync'
        @module_async who: 'async'
      .call ->
        n.registry.registered('module_sync').should.be.true()
        n.registry.registered('module_async').should.be.true()
        logs.should.eql ['Hello sync', 'Hello async']
      n.promise()

    it.skip 'namespace accept array', ->
      value = null
      nikita()
      .registry.register ['this', 'is', 'a', 'function'], ({options}, callback) ->
        value = options.value
        callback null, true
      .this.is.a.function value: 'yes'
      .next (err, {status}) ->
        throw err if err
        status.should.be.true()
      .promise()

    it.skip 'namespace accept object', ->
      value_a = value_b = null
      nikita()
      .registry.register
        namespace:
          "": ({options}, callback) ->
            value_a = options.value
            callback null, true
          "child": ({options}, callback) ->
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

    it.skip 'namespace call function with children', ->
      value_a = value_b = null
      nikita()
      .registry.register ['a', 'function'], ({options}, callback) ->
        value_a = options.value
        callback null, true
      .registry.register ['a', 'function', 'with', 'a', 'child'], ({options}, callback) ->
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

    it.skip 'throw error unless registered', ->
      (->
        nikita().invalid()
      ).should.throw 'nikita(...).invalid is not a function'
      (->
        n = nikita()
        n.registry.register ['ok', 'and', 'valid'], (->)
        n.ok.and.invalid()
      ).should.throw 'n.ok.and.invalid is not a function'
  
  describe 'parent', ->
    
    it.skip 'is available from nikita instance', ->
      nikita
      .registry.register 'my_function', ({options}, callback) ->
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
