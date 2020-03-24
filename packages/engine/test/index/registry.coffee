
nikita = require '../../src'
registry = require '../../src/registry'

describe 'index registry', ->

  it 'call action from global registry', ->
    nikita
    .call ->
      registry.register 'my_function', ({options}) ->
        pass_a_key: options.a_key
    .call ->
      {pass_a_key} = await nikita.my_function a_key: 'a value'
      pass_a_key.should.eql 'a value'
    .call ->
      registry.unregister 'my_function'
  
  describe 'error', ->

    it 'root action not defined', ->
      (->
        nikita.invalid()
      ).should.throw 'nikita.invalid is not a function'

    it 'undefined action inside a registered namespace', ->
      # Internally, the proxy for nikita is not the same as for its children
      registry.register ['ok', 'and', 'valid'], (->)
      (->
        nikita.ok.and.invalid()
      ).should.throw 'nikita.ok.and.invalid is not a function'
      registry.unregister ['ok', 'and', 'valid']

    it 'parent name not defined child action undefined', ->
      (->
        nikita.not.an.action()
      ).should.throw 'Cannot read property \'an\' of undefined'
