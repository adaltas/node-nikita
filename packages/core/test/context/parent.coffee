
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "parent"', ->
    
  it 'default values', ->
    nikita
    # First level
    .call ({parent}) ->
      (parent is undefined).should.be.true()
    # Second level
    .call ->
      @call ({parent}) ->
        (parent.parent is undefined).should.be.true()
        parent.options.disabled.should.be.false()
    # Third level
    .call ->
      @call ->
        @call ({parent}) ->
          (parent.parent.parent is undefined).should.be.true()
          parent.parent.options.disabled.should.be.false()
    .promise()
  
  it 'passed to action', ->
    nikita
    # Second level
    .call my_key: 'value 1', ->
      @call ({parent}) ->
        parent.options.my_key.should.eql 'value 1'
    # Third level
    .call my_key: 'value 1', ->
      @call my_key: 'value 2', ->
        @call ({parent}) ->
          parent.parent.options.my_key.should.eql 'value 1'
          parent.options.my_key.should.eql 'value 2'
    .promise()
  
  it 'defined in action', ->
    nikita()
    .registry.register( 'level_1', key: 'value 1', handler: ->
      @call ({parent}) ->
        parent.options.key.should.eql 'value 1'
    )
    .registry.register( 'level_2_1', key: 'value 1', handler: ->
      @level_2_2()
    )
    .registry.register( 'level_2_2', key: 'value 2', handler: ->
      @call ({parent}) ->
        parent.parent.options.key.should.eql 'value 1'
        parent.options.key.should.eql 'value 2'
    )
    # Second level
    .level_1()
    # Third level
    .level_2_1()
    .promise()
