
nikita = require '../../../src'
{tags, scratch} = require '../../test'
  
return unless tags.api

describe 'api before', ->

  describe 'event', ->

    it 'is a string and match a action type', ->
      history = []
      nikita()
      .registry.register 'good_handler', (->)
      .registry.register 'bad_handler', (->)
      .before 'good_handler', ({options}) ->
        history.push options.key
      .good_handler
        key: 'value 1'
      .good_handler
        key: 'value 2'
      .call ->
        history.should.eql ['value 1', 'value 2']
      .promise()

    it 'is an object and match options', ->
      history = []
      nikita()
      .registry.register 'handler', (->)
      .before action: 'handler', key: 'value 2', ({options}) ->
        history.push options.key
      .handler
        key: 'value 1'
      .handler
        key: 'value 2'
      .call ->
        history.should.eql ['value 2']
      .promise()

  describe 'handler', ->

    it 'a sync function with sync handler', ->
      history = []
      nikita()
      .registry.register 'sync_fn', ((_) ->)
      .before 'sync_fn', (_) ->
        history.push 'before sync'
      .call ->
        history.push 'call 1'
      .sync_fn ->
        history.push 'sync 1'
      .call ->
        history.push 'call 2'
      .sync_fn ->
        history.push 'sync 2'
      .call ->
        history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'before sync', 'sync 1'
          'call 2', 'before sync', 'sync 2'
          'call 3'
        ]
      .promise()

    it 'a sync function with async handler', ->
      history = []
      nikita()
      .registry.register 'afunction', ((_) ->)
      .before 'afunction', (_, callback) ->
        setImmediate ->
          history.push 'before sync'
          callback()
      .call ->
        history.push 'call 1'
      .afunction ->
        history.push 'sync 1'
      .call ->
        history.push 'call 2'
      .afunction ->
        history.push 'sync 2'
      .call ->
        history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'before sync', 'sync 1'
          'call 2', 'before sync', 'sync 2'
          'call 3'
        ]
      .promise()

    it 'an async function with sync handler', ->
      history = []
      nikita()
      .registry.register 'async_fn', ((_, callback) -> setImmediate callback)
      .before 'async_fn', (_) ->
        history.push 'before async'
        return false
      .call ->
        history.push 'call 1'
      .async_fn
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 1'
      .call ->
        history.push 'call 2'
      .async_fn
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 2'
      .call ->
        history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'before async', 'async 1'
          'call 2', 'before async', 'async 2'
          'call 3'
        ]
      .promise()

    it 'an async function with async handler', ->
      history = []
      nikita()
      .registry.register 'async_fn', ((_, callback) -> setImmediate callback)
      .before 'async_fn', (_, callback) ->
        setImmediate ->
          history.push 'before async'
          callback null, false
      .call ->
        history.push 'call 1'
      .async_fn
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 1'
      .call ->
        history.push 'call 2'
      .async_fn
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 2'
      .call ->
        history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'before async', 'async 1'
          'call 2', 'before async', 'async 2'
          'call 3'
        ]
      .promise()

    it 'an namespaced async function with async handler', ->
      history = []
      nikita()
      .registry.register ['a','namespaced','func'], ((_, callback) -> setImmediate callback)
      .before ['a','namespaced','func'], (_, callback) ->
        setImmediate ->
          history.push 'before async'
          callback null, false
      .call ->
        history.push 'call 1'
      .a.namespaced.func
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 1'
      .call ->
        history.push 'call 2'
      .a.namespaced.func
        target: "#{scratch}/a_file"
      , ->
        history.push 'async 2'
      .call ->
        history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'before async', 'async 1'
          'call 2', 'before async', 'async 2'
          'call 3'
        ]
      .promise()
