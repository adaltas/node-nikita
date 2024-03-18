
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'session.handler.config', ->
  return unless test.tags.api
    
  it 'ensure it is not polluted', ->
    nikita.call ({config}) ->
      config.should.eql {}
    
  it 'ensure it is cloned', ->
    config =
      key_1: 'value 1'
      object_1:
        key_1_1: 'value 1.1'
    await nikita.call config, ({config}) ->
      config.key_1 = 'value 1 modified'
      config.object_1.key_1_1 = 'value 1.1 modified'
      config.object_1.key_1_2 = 'value 1.2 created'
      config.key_2 = 'value 2 created'
    config.should.eql
      key_1: 'value 1'
      object_1:
        key_1_1: 'value 1.1'
      
  it 'context config dont conflict', ->
    nikita.call
      context: true
    , ({config}) ->
      config.context.should.be.true()
    
  it 'parent config dont conflict', ->
    nikita.call
      parent: true
    , ({config}) ->
      config.parent.should.be.true()
