
nikita = require '../../src'
context = require '../../src/context'

describe 'api propagation', ->
  
  it 'propagate global option', ->
    context.propagation.my_global_option = true
    n = nikita
    n
    .call ->
      n.propagation.my_global_option.should.be.true()
    .call my_global_option: 'value', (options) ->
      options.my_global_option.should.be.equal 'value'
      @call (options) ->
        options.my_global_option.should.be.equal 'value'
        @call (options) ->
          options.my_global_option.should.be.equal 'value'
    .call ->
      delete context.propagation.my_global_option
    .promise()
      
  it 'propagate context option', ->
    n = nikita
      propagation: my_context_option: true
    n
    .call ->
      n.propagation.my_context_option.should.be.true()
    .call my_context_option: 'value', (options) ->
      options.my_context_option.should.be.equal 'value'
      @call (options) ->
        options.my_context_option.should.be.equal 'value'
        @call (options) ->
          options.my_context_option.should.be.equal 'value'
    .call ->
      n.propagation.my_context_option.should.be.true()
    .promise()
  
  it 'dont propagate context options', ->
    n = nikita
    n
    .call ->
      n.propagation.header.should.be.false()
    .call header: 'h1', (options) ->
      (options.header is undefined).should.be.true()
      @call header: 'h2', (options) ->
        (options.header is undefined).should.be.true()
    .promise()

  it 'global dont overwrite local options', ->
    n = nikita
      global_param: true
    n.propagation.parent_param_propagated = true
    n.registry.register 'achild', (options, callback) ->
      options.local_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      (options.parent_param_unpropagated is undefined).should.be.true()
      options.global_param.should.be.true()
      callback null, true
    n.registry.register 'aparent', (options, callback) ->
      options.global_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      options.parent_param_unpropagated.should.be.true()
      @achild
        local_param: true
      .next (err, status) -> callback err, true
    n.aparent
      parent_param_propagated: true
      parent_param_unpropagated: true
    .promise()
  
  it 'can be disabled in action', ->
    n = nikita
    n
      propagation: a_key: true
      a_key: 'a value'
    .call (options) ->
      options.a_key.should.eql 'a value'
    .call a_key: null, (options) ->
      (options.a_key is null).should.be.true()
      @call (options) ->
        (options.a_key is null).should.be.true()
        @call (options) ->
          (options.a_key is null).should.be.true()
    .call (options) ->
      options.a_key.should.eql 'a value'
    .promise()
