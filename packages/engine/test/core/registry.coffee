
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.register', ->

  describe 'global', ->

    it 'register', ->
      nikita.registry.register 'my_function', (->)
      nikita.registry.registered('my_function').should.be.true()
      nikita.registry.unregister 'my_function'

    it 'call action from global registry', ->
      nikita
      .call ->
        nikita.registry.register 'my_function', ({options}) ->
          pass_a_key: options.a_key
      .call ->
        {pass_a_key} = await nikita.my_function a_key: 'a value'
        pass_a_key.should.eql 'a value'
      .call ->
        nikita.registry.unregister 'my_function'

    it 'call action from local registry', ->
      nikita
      .call ({context, registry})->
        registry.register 'my_function', ({options}) ->
          pass_a_key: options.a_key
        {pass_a_key} = await this.my_function a_key: 'a value'
        pass_a_key.should.eql 'a value'

    it 'overwrite options with namespace registration', ->
      n = nikita ({registry}) ->
        # Register a namespace
        registry.register ['my', 'function'], key: 'a', handler: ({options}) -> options.key
        registry.register ['my', 'function'], key: 'b', handler: ({options}) -> options.key
      result = await n.my.function()
      result.should.eql 'b'

    it 'overwrite options with multi registration', ->
      n = nikita ({registry}) ->
        registry.register
          'my': 'function': key: 'a', handler: ({options}) -> options.key
        registry.register
          'my': 'function': key: 'b', handler: ({options}) -> options.key
      result = await n.my.function()
      result.should.eql 'b'
