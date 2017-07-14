
nikita = require '../../src'
context = require '../../src/context'
test = require '../test'
fs = require 'fs'

describe 'api propagation', ->
  
  it 'propagate global option', (next) ->
    context.propagation.my_global_option = true
    n = nikita
    .call ->
      n.propagation.my_global_option.should.be.true()
    .call my_global_option: 'value', (options) ->
      options.my_global_option.should.be.equal 'value'
      @call (options) ->
        options.my_global_option.should.be.equal 'value'
    .call ->
      delete context.propagation.my_global_option
    .then next
      
  it 'propagate context option', (next) ->
    n = nikita
      propagation: my_context_option: true
    .call ->
      n.propagation.my_context_option.should.be.true()
    .call my_context_option: 'value', (options) ->
      options.my_context_option.should.be.equal 'value'
      @call (options) ->
        options.my_context_option.should.be.equal 'value'
    .then next
  
  it 'dont propagate context options', (next) ->
    n = nikita
    .call ->
      n.propagation.header.should.be.false()
    .call header: 'h1', (options) ->
      (options.header is undefined).should.be.true()
      @call header: 'h2', (options) ->
        (options.header is undefined).should.be.true()
    .then next

  it 'global dont overwrite local options', (next) ->
    m = nikita
      global_param: true
    m.propagation.parent_param_propagated = true
    m.registry.register 'achild', (options, callback) ->
      options.local_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      (options.parent_param_unpropagated is undefined).should.be.true()
      options.global_param.should.be.true()
      callback null, true
    m.registry.register 'aparent', (options, callback) ->
      options.global_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      options.parent_param_unpropagated.should.be.true()
      @achild
        local_param: true
      .then (err, status) -> callback err, true
    m.aparent
      parent_param_propagated: true
      parent_param_unpropagated: true
    .then next
