
import nikita from '@nikitajs/core'
import memory from '@nikitajs/core/plugins/pubsub/engines/memory'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)


describe 'plugins.pubsub', ->
  return unless test.tags.api
  
  they 'set then get', ({ssh}) ->
    engine = memory()
    await nikita
      $ssh: ssh
      $pubsub: engine
    , ({tools: {pubsub}}) ->
      await pubsub.set 'a_key', 'a value'
    nikita
      $pubsub: engine
    , ({tools: {pubsub}}) ->
      value = await pubsub.get 'a_key'
      value.should.eql 'a value'
  
  they 'get then set', ({ssh}) ->
    engine = memory()
    new Promise (resolve, reject) ->
      nikita
        $ssh: ssh
        $pubsub: engine
      , ({tools: {pubsub}}) ->
        try
          value = await pubsub.get 'a_key'
          value.should.eql 'a value'
          resolve()
        catch err then reject err
      nikita
        $pubsub: engine
      , ({tools: {pubsub}}) ->
        await pubsub.set 'a_key', 'a value'
