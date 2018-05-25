
nikita = require '../../src'
context = require '../../src/context'

describe 'options "cascade"', ->
  
  describe 'global', ->
  
    it 'propagate option', ->
      context.cascade.my_global_option = true
      n = nikita
      n
      .call ->
        n.cascade.my_global_option.should.be.true()
      .call my_global_option: 'value', (options) ->
        options.my_global_option.should.be.equal 'value'
        @call (options) ->
          options.my_global_option.should.be.equal 'value'
          @call (options) ->
            options.my_global_option.should.be.equal 'value'
      .call ->
        delete context.cascade.my_global_option
      .promise()

    it 'dont overwrite context options', ->
      n = nikita
        global_param: true
      n.cascade.parent_param_cascaded = true
      n.registry.register 'achild', (options, callback) ->
        options.local_param.should.be.true()
        options.parent_param_cascaded.should.be.true()
        (options.parent_param_uncascaded is undefined).should.be.true()
        options.global_param.should.be.true()
        callback null, true
      n.registry.register 'aparent', (options, callback) ->
        options.global_param.should.be.true()
        options.parent_param_cascaded.should.be.true()
        options.parent_param_uncascaded.should.be.true()
        @achild
          local_param: true
        .next (err, status) -> callback err, true
      n.aparent
        parent_param_cascaded: true
        parent_param_uncascaded: true
      .promise()
        
  describe 'context', ->
      
    it 'propagate option', ->
      n = nikita
        cascade: my_context_option: true
      n
      .call ->
        n.cascade.my_context_option.should.be.true()
      .call my_context_option: 'value', (options) ->
        options.my_context_option.should.be.equal 'value'
        @call (options) ->
          options.my_context_option.should.be.equal 'value'
          @call (options) ->
            options.my_context_option.should.be.equal 'value'
      .call ->
        n.cascade.my_context_option.should.be.true()
      .promise()
  
  it 'dont cascade context options', ->
    n = nikita
    n
    .call ->
      n.cascade.header.should.be.false()
    .call header: 'h1', (options) ->
      (options.header is undefined).should.be.true()
      @call header: 'h2', (options) ->
        (options.header is undefined).should.be.true()
    .promise()
  
  it 'can be disabled in action', ->
    n = nikita
    n
      cascade: a_key: true
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
