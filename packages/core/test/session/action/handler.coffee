
import session from '@nikitajs/core/session'
import metadataRegister from '@nikitajs/core/plugins/metadata/register'
import test from '../../test.coffee'

describe 'session.action.handler', ->
  return unless test.tags.api
  
  describe 'root action', ->
    
    it 'return an promise', ->
      {key} = await session ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'
          
    it 'return an object', ->
      {key} = await session ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'namespaced action', ->

    it 'return a promise', ->
      {key} = await session ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'

    it 'return an object', ->
      {key} = await session ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'result', ->

    it 'return a user resolved promise', ->
      session ({config}) ->
        new Promise (accept, reject) ->
          setImmediate -> accept output: 'ok'
      .should.be.finally.containEql output: 'ok'

    it 'return an action resolved promise', ->
      session
        $plugins: [
          metadataRegister
        ]
        $register:
          call: '@nikitajs/core/actions/call'
      , ({config}) ->
        @call ->
          new Promise (accept, reject) ->
            setImmediate -> accept output: 'ok'
      .should.be.finally.containEql output: 'ok'
