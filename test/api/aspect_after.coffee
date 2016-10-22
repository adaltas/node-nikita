
mecano = require '../../src'
test = require '../test'

describe 'api after', ->

  describe 'event', ->

    it 'is a string and match a action type', (next) ->
      history = []
      mecano()
      .register 'good_handler', (->)
      .register 'bad_handler', (->)
      .after 'good_handler', (options) -> history.push options.key
      .good_handler key: 'value 1'
      .good_handler key: 'value 2'
      .then (err) ->
        history.should.eql ['value 1', 'value 2'] unless err
        next err

    it 'is an object and match options', (next) ->
      history = []
      mecano()
      .register 'handler', (->)
      .after type: 'handler', key: 'value 2', (options) ->
        history.push options.key
      .handler key: 'value 1'
      .handler key: 'value 2'
      .then (err) ->
        history.should.eql ['value 2'] unless err
        next err

  describe 'handler', ->
  
    it 'a sync function with sync handler', (next) ->
      history = []
      mecano()
      .register 'sync_fn', ((_) -> history.push 'sync handler' )
      .after 'sync_fn', (_) -> history.push 'after sync'
      .call -> history.push 'call 1'
      .sync_fn -> history.push 'sync callback 1'
      .call -> history.push 'call 2'
      .sync_fn -> history.push 'sync callback 2'
      .call -> history.push 'call 3'
      .then (err, status) ->
        history.should.eql [
          'call 1', 'sync handler', 'after sync', 'sync callback 1'
          'call 2', 'sync handler', 'after sync', 'sync callback 2'
          'call 3'
        ] unless err
        next err
  
    it 'a sync function with async handler', (next) ->
      history = []
      mecano()
      .register 'afunction', ((_) -> history.push 'sync handler' )
      .after 'afunction', (_, callback) ->
        setImmediate ->
          history.push 'after sync'
          callback()
      .call -> history.push 'call 1'
      .afunction -> history.push 'sync callback 1'
      .call -> history.push 'call 2'
      .afunction -> history.push 'sync callback 2'
      .call -> history.push 'call 3'
      .then (err, status) ->
        history.should.eql [
          'call 1', 'sync handler', 'after sync', 'sync callback 1'
          'call 2', 'sync handler', 'after sync', 'sync callback 2'
          'call 3'
        ]
        next()

  describe 'error', ->
    
    it 'register sync function and throw error', (next) ->
      mecano()
      .register 'afunction', ((_) -> )
      .after 'afunction', (_) ->
        throw Error 'CatchMe'
      .afunction (err, status) ->
        err.message.should.eql 'CatchMe'
      .then (err) ->
        err.message.should.eql 'CatchMe'
        next()
          
    it 'register sync function and throw error', (next) ->
      mecano()
      .register 'afunction', ((_) -> )
      .after 'afunction', (_, callback) ->
        setImmediate -> callback Error 'CatchMe'
      .afunction (err, status) ->
        err.message.should.eql 'CatchMe'
      .then (err) ->
        err.message.should.eql 'CatchMe'
        next()
        
    it 'handler registered with namespace', (next) ->
      history = []
      mecano()
      .register ['hello', 'baby'],  ((_) -> history.push 'hello_baby_handler')
      .after 'hello', (_, callback) ->
        setImmediate ->
          history.push 'after sync'
          callback()
      .hello.baby (err,status) ->
        history.push 'call_hello_baby_handler'
      .then (err, status) ->
        history.should.eql [
          'hello_baby_handler', 'call_hello_baby_handler', 'after sync'
        ]
        next()
