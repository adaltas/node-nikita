
nikita = require '../../src'
registry = require '../../src/registry'

describe 'actions.call', ->

  it 'call action from global registry', ->
    nikita
    .call ->
      registry.register 'my_function', ({config}) ->
        pass_a_key: config.a_key
    .call ->
      {pass_a_key} = await nikita.my_function a_key: 'a value'
      pass_a_key.should.eql 'a value'
    .call ->
      registry.unregister 'my_function'
