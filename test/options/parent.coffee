
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "parent"', ->

  scratch = test.scratch @
    
  it 'default values', ->
    nikita
    # First level
    .call (options) ->
      (options.parent is undefined).should.be.true()
    # Second level
    .call ->
      @call (options) ->
        (options.parent.parent is undefined).should.be.true()
        options.parent.disabled.should.be.false()
    # Third level
    .call ->
      @call ->
        @call (options) ->
          (options.parent.parent.parent is undefined).should.be.true()
          options.parent.parent.disabled.should.be.false()
    .promise()
      
  it 'passed to action', ->
    nikita
    # Second level
    .call my_key: 'value 1', ->
      @call (options) ->
        options.parent.my_key.should.eql 'value 1'
    # Third level
    .call my_key: 'value 1', ->
      @call my_key: 'value 2', ->
        @call (options) ->
          options.parent.parent.my_key.should.eql 'value 1'
          options.parent.my_key.should.eql 'value 2'
    .promise()
      
  it 'defined in action', ->
    nikita()
    .registry.register( 'level_1', key: 'value 1', handler: ->
      @call (options) ->
        options.parent.key.should.eql 'value 1'
    )
    .registry.register( 'level_2_1', key: 'value 1', handler: ->
      @level_2_2()
    )
    .registry.register( 'level_2_2', key: 'value 2', handler: ->
      @call (options) ->
        options.parent.parent.key.should.eql 'value 1'
        options.parent.key.should.eql 'value 2'
    )
    # Second level
    .level_1()
    # Third level
    .level_2_1()
    .promise()
