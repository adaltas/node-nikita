
import nikita from '@nikitajs/core'
import registry from '@nikitajs/core/registry'
import test from '../test.coffee'

describe 'registry.register', ->
  return unless test.tags.api

  describe 'namespace', ->

    it 'options chain default to current registry', ->
      reg = registry.create()
      (await reg.register('action', (->))).should.eql reg

    it 'is an array', ->
      reg = await registry
      .create()
      .register ['this', 'is', 'a', 'function'],
        config: key: 'value'
        handler: (->)
      reg.get ['this', 'is', 'a', 'function']
      .then ({config}) -> config.key.should.eql 'value'

    it 'is a string', ->
      reg = await registry
      .create()
      .register 'my_function',
        config: key: 'value'
        handler: (->)
      reg.get 'my_function'
      .then ({config}) -> config.key.should.eql 'value'

    it 'is an object', ->
      reg = await registry
      .create()
      .register
        'my': 'function':
          config: key: 'value'
          handler: (->)
      reg
      .get ['my', 'function']
      .then ({config}) -> config.key.should.eql 'value'

    it 'overwrite an existing action', ->
      reg = registry.create()
      reg.register 'my_function',
        config: key: 1
        handler: -> 'my_function'
      reg.register 'my_function',
        config: key: 2
        handler: -> 'my_function'
      reg
      .get 'my_function'
      .then ({config}) -> config.key.should.eql 2

    it 'namespace is object with empty key', ->
      reg = registry.create()
      await reg.register
        'my': 'actions':
          '':
            config: key: 1
            handler: (->)
          'child':
            config: key: 2
            handler: (->)
      reg.get(['my', 'actions'])
      .then ({config}) -> config.key.should.eql 1
      reg.get(['my', 'actions', 'child'])
      .then ({config}) -> config.key.should.eql 2

    it 'namespace with children', ->
      reg = registry.create()
      reg.register ['a', 'function'],
        config: key: 1
        handler: (->)
      reg.register ['a', 'function', 'with', 'child'],
        config: key: 2
        handler: (->)
      reg.get(['a', 'function'])
      .then ({config}) -> config.key.should.eql 1
      reg.get(['a', 'function', 'with', 'child'])
      .then ({config}) -> config.key.should.eql 2

  describe 'value', ->

    it 'is a function', ->
      reg = registry.create()
      reg.register 'an_action', (-> 'ok')
      reg.registered 'an_action'

    it 'is an object', ->
      reg = registry.create()
      reg.register 'an_action',
        config: a_key: 'a value'
        handler: (->)
      reg.registered 'an_action'

    it 'is a string, function style', ->
      # Room for improvement in the future
      nikita ({registry}) ->
        await registry.register 'an_action', '@nikitajs/core/actions/execute'
        result = registry.registered 'an_action'
          .should.eql true
        {metadata, config} = await registry.get 'an_action'
        metadata.module.should.eql '@nikitajs/core/actions/execute'
        should(config).be.undefined()

    it 'is a string, object style', ->
      # Room for improvement in the future
      nikita ({registry}) ->
        await registry.register
          'an_action':
            '': '@nikitajs/core/actions/execute'
            'child': '@nikitajs/core/actions/execute'
        registry.registered 'an_action'
          .should.eql true
        registry.registered ['an_action', 'child']
          .should.eql true
        {metadata, config} = await registry.get 'an_action'
        metadata.module.should.eql '@nikitajs/core/actions/execute'
        should(config).be.undefined()
        {metadata, config} = await registry.get ['an_action', 'child']
        metadata.module.should.eql '@nikitajs/core/actions/execute'
        should(config).be.undefined()

  describe 'parent', ->
    
    it.skip 'is available from nikita instance', ->
      nikita
      .registry.register 'my_function', ({config}, callback) ->
        config.my_option.should.eql 'my value'
        process.nextTick ->
          callback null, true
      n = nikita()
      n.registry.registered('my_function').should.be.true()
      n.my_function
        my_option: 'my value'
      n.next (err, {$status}) ->
        throw err if err
        $status.should.be.true()
        nikita.registry.unregister 'my_function'
      n.promise()
