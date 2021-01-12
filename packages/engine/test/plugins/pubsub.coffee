
memory = require '../../src/plugins/pubsub/engines/memory'
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh


describe 'plugins.pubsub', ->
  
  they 'set then get', ({ssh}) ->
    engine = memory()
    await nikita
      ssh: ssh
      metadata:
        pubsub: engine
    , ({tools: {pubsub}}) ->
      await pubsub.set 'a_key', 'a value'
    nikita
      metadata:
        pubsub: engine
    , ({tools: {pubsub}}) ->
      value = await pubsub.get 'a_key'
      value.should.eql 'a value'
  
  they 'get then set', ({ssh}) ->
    engine = memory()
    new Promise (resolve, reject) ->
      nikita
        ssh: ssh
        metadata:
          pubsub: engine
      , ({tools: {pubsub}}) ->
        try
          value = await pubsub.get 'a_key'
          value.should.eql 'a value'
          resolve()
        catch err then reject err
      nikita
        metadata:
          pubsub: engine
      , ({tools: {pubsub}}) ->
        await pubsub.set 'a_key', 'a value'
