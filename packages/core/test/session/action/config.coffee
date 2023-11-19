
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'session.handler.config', ->
  return unless test.tags.api
    
  it 'ensure it is not polluted', ->
    nikita.call ({config}) ->
      config.should.eql {}
      
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
