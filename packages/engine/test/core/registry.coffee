
nikita = require '../../src'
registry = require '../../src/registry'

describe 'registry.register', ->

  describe 'global', ->

    it 'register', ->
      nikita.registry.register 'my_function', (->)
      nikita.registry.registered('my_function').should.be.true()
      nikita.registry.unregister 'my_function'

    it.skip 'call a function', ->
      nikita()
      .call ->
        nikita.registry.register 'my_function', ({options}) ->
          a_key: options.a_key
      .call ->
        nikita.my_function a_key: 'a value'
        # {a_key} = await nikita.my_function a_key: 'a value'
        # a_key.should.eql 'a value'
      .call ->
        nikita.registry.unregister 'my_function'
