
mecano = require '../../src'
test = require '../test'

describe 'api before', ->

  scratch = test.scratch @

  describe 'event', ->

    it 'is a string and match a action type', (next) ->
      history = []
      mecano()
      .register 'good_handler', (->)
      .register 'bad_handler', (->)
      .before 'good_handler', (options) ->
        history.push options.key
      .good_handler
        key: 'value 1'
      .good_handler
        key: 'value 2'
      .then (err) ->
        history.should.eql ['value 1', 'value 2'] unless err
        next err

    it 'is an object and match options', (next) ->
      history = []
      mecano()
      .register 'handler', (->)
      .before type: 'handler', key: 'value 2', (options) ->
        history.push options.key
      .handler
        key: 'value 1'
      .handler
        key: 'value 2'
      .then (err) ->
        history.should.eql ['value 2'] unless err
        next err

  describe 'handler', ->

    it 'a sync function with sync handler', (next) ->
      history = []
      mecano()
      .register 'sync_fn', ((_) ->)
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
      .then (err, status) ->
        history.should.eql [
          'call 1', 'before sync', 'sync 1'
          'call 2', 'before sync', 'sync 2'
          'call 3'
        ] unless err
        next err

    it 'a sync function with async handler', (next) ->
      history = []
      mecano()
      .register 'afunction', ((_) ->)
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
      .then (err, status) ->
        history.should.eql [
          'call 1', 'before sync', 'sync 1'
          'call 2', 'before sync', 'sync 2'
          'call 3'
        ]
        next()

    it 'an async function with sync handler', (next) ->
      history = []
      mecano()
      .register 'async_fn', ((_, callback) -> setImmediate callback)
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
      .then (err, status) ->
        history.should.eql [
          'call 1', 'before async', 'async 1'
          'call 2', 'before async', 'async 2'
          'call 3'
        ]
        next()

    it 'an async function with async handler', (next) ->
      history = []
      mecano()
      .register 'async_fn', ((_, callback) -> setImmediate callback)
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
      .then (err, status) ->
        history.should.eql [
          'call 1', 'before async', 'async 1'
          'call 2', 'before async', 'async 2'
          'call 3'
        ]
        next()
