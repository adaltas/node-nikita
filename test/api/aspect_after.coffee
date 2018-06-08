
nikita = require '../../src'
test = require '../test'

describe 'api after', ->

  describe 'event', ->

    it 'is a string and match a action type', ->
      history = []
      nikita()
      .registry.register 'good_handler', (->)
      .registry.register 'bad_handler', (->)
      .after 'good_handler', (options) -> history.push options.key
      .good_handler key: 'value 1'
      .good_handler key: 'value 2'
      .call ->
        history.should.eql ['value 1', 'value 2']
      .promise()

    it 'is an object and match options', ->
      history = []
      nikita()
      .registry.register 'handler', (->)
      .after action: 'handler', key: 'value 2', (options) ->
        history.push options.key
      .handler key: 'value 1'
      .handler key: 'value 2'
      .call ->
        history.should.eql ['value 2']
      .promise()

  describe 'handler', ->

    it 'a sync function with sync handler', ->
      history = []
      nikita()
      .registry.register 'sync_fn', ((_) -> history.push 'sync handler' )
      .after 'sync_fn', (_) -> history.push 'after sync'
      .call -> history.push 'call 1'
      .sync_fn -> history.push 'sync callback 1'
      .call -> history.push 'call 2'
      .sync_fn -> history.push 'sync callback 2'
      .call -> history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'sync handler', 'after sync', 'sync callback 1'
          'call 2', 'sync handler', 'after sync', 'sync callback 2'
          'call 3'
        ]
      .promise()

    it 'a sync function with async handler', ->
      history = []
      nikita()
      .registry.register 'afunction', ((_) -> history.push 'sync handler' )
      .after 'afunction', (_, callback) ->
        setImmediate ->
          history.push 'after sync'
          callback()
      .call -> history.push 'call 1'
      .afunction -> history.push 'sync callback 1'
      .call -> history.push 'call 2'
      .afunction -> history.push 'sync callback 2'
      .call -> history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'sync handler', 'after sync', 'sync callback 1'
          'call 2', 'sync handler', 'after sync', 'sync callback 2'
          'call 3'
        ]
      .promise()

    it 'a namespaced sync function with async handler', ->
      history = []
      nikita()
      .registry.register ['a','namespaced','function'], ((_) -> history.push 'sync handler' )
      .after ['a','namespaced', 'function'], (_, callback) ->
        setImmediate ->
          history.push 'after sync'
          callback()
      .call -> history.push 'call 1'
      .a.namespaced.function -> history.push 'sync callback 1'
      .call -> history.push 'call 2'
      .a.namespaced.function -> history.push 'sync callback 2'
      .call -> history.push 'call 3'
      .call ->
        history.should.eql [
          'call 1', 'sync handler', 'after sync', 'sync callback 1'
          'call 2', 'sync handler', 'after sync', 'sync callback 2'
          'call 3'
        ]
      .promise()

  describe 'error', ->

    it 'register sync function and throw error', ->
      nikita()
      .registry.register 'afunction', ( -> )
      .after 'afunction', (_) ->
        throw Error 'CatchMe'
      .afunction (err, status) ->
        err.message.should.eql 'CatchMe'
      .next (err) ->
        err.message.should.eql 'CatchMe'
      .promise()

    it 'register sync function and throw error', ->
      nikita()
      .registry.register 'afunction', ( -> )
      .after 'afunction', (_, callback) ->
        setImmediate -> callback Error 'CatchMe'
      .afunction (err, status) ->
        err.message.should.eql 'CatchMe'
      .next (err) ->
        err.message.should.eql 'CatchMe'
      .promise()
