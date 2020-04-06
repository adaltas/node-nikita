
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.register', ->

  describe 'namespace', ->

    it 'options chain default to current registry', ->
      reg = registry.create()
      (await reg.register('action', (->))).should.eql reg

    it 'is an array', ->
      reg = await registry
      .create()
      .register ['this', 'is', 'a', 'function'], key: 'value', handler: (->)
      reg.get ['this', 'is', 'a', 'function']
      .then ({options}) -> options.key.should.eql 'value'

    it 'is a string', ->
      reg = await registry
      .create()
      .register 'my_function', key: 'value', handler: (->)
      reg.get 'my_function'
      .then ({options}) -> options.key.should.eql 'value'

    it 'is an object', ->
      reg = await registry
      .create()
      .register
        'my': 'function': key: 'value', handler: (->)
      reg
      .get ['my', 'function']
      .then ({options}) -> options.key.should.eql 'value'

    it 'overwrite an existing action', ->
      reg = registry.create()
      reg.register 'my_function', key: 1, handler: -> 'my_function'
      reg.register 'my_function', key: 2, handler: -> 'my_function'
      reg
      .get 'my_function'
      .then ({options}) -> options.key.should.eql 2

    it 'namespace is object with empty key', ->
      reg = registry.create()
      await reg.register
        'my': 'actions':
          '': key: 1, handler: (->)
          'child': key: 2, handler: (->)
      reg.get(['my', 'actions'])
      .then ({options}) -> options.key.should.eql 1
      reg.get(['my', 'actions', 'child'])
      .then ({options}) -> options.key.should.eql 2

    it 'namespace with children', ->
      reg = registry.create()
      reg.register ['a', 'function'], key: 1, handler: (->)
      reg.register ['a', 'function', 'with', 'child'], key: 2, handler: (->)
      reg.get(['a', 'function'])
      .then ({options}) -> options.key.should.eql 1
      reg.get(['a', 'function', 'with', 'child'])
      .then ({options}) -> options.key.should.eql 2

  describe 'value', ->

    it 'is a function', ->
      reg = registry.create()
      reg.register 'an_action', (-> 'ok')
      reg.registered 'an_action'

    it 'is an object', ->
      reg = registry.create()
      reg.register 'an_action', a_key: 'a value', handler: (->)
      reg.registered 'an_action'

    it 'is a string', ->
      # Room for improvement in the future
      nikita ({registry}) ->
        await registry.register 'an_action', '@nikitajs/engine/src/actions/ssh'
        result = await @registry.registered 'an_action'
        .should.resolvedWith true
        {metadata, options} = await @registry.get 'an_action'
        metadata.module.should.eql '@nikitajs/engine/src/actions/ssh'
        options.should.eql {}

    it 'is a string', ->
      # Room for improvement in the future
      nikita ({registry}) ->
        await registry.register
          'an_action':
            '': '@nikitajs/engine/src/actions/ssh'
            'child': '@nikitajs/engine/src/actions/ssh'
        result = await @registry.registered 'an_action'
        .should.resolvedWith true
        result = await @registry.registered ['an_action', 'child']
        .should.resolvedWith true
        {metadata, options} = await @registry.get 'an_action'
        metadata.module.should.eql '@nikitajs/engine/src/actions/ssh'
        options.should.eql {}
        {metadata, options} = await @registry.get ['an_action', 'child']
        metadata.module.should.eql '@nikitajs/engine/src/actions/ssh'
        options.should.eql {}

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
