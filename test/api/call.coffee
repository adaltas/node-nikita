
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api call', ->

  scratch = test.scratch @

  describe 'sync', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/file_a"
      , (err) ->
        touched++
      .call (options) ->
        called++
      .touch
        destination: "#{scratch}/file_b"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'execute a callback', (next) ->
      called = 0
      mecano
      # 1st arg options with handler, 2nd arg a callback
      .call handler: (->), (err, status) ->
        status.should.be.false() unless err
        called++ unless err
      # 1st arg handler, 2nd arg a callback
      .call (->), (err, status) ->
        status.should.be.false() unless err
        called++ unless err
      .then (err, status) ->
        called.should.eql 2
        next()

    it 'pass options', (next) ->
      mecano
      .call test: true, (options) ->
        options.test.should.be.true()
      .then next

    it 'pass multiple options', (next) ->
      mecano
      .call {test1: true}, {test2: true}, (options) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
      .then next
    
    it 'string requires a module', (next) ->
      logs = []
      mecano
      .on 'text', (l) -> logs.push l
      .call who: 'us', 'test/resources/module_sync'
      .then (err) ->
        logs[0].message.should.eql 'Hello us' unless err
        next err

  describe 'async', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          called++
          next()
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'execute a callback', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          next()
      , (err, status) ->
        called++ unless err
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'pass options', (next) ->
      mecano
      .call test: true, (options, next) ->
        options.test.should.be.true()
        next()
      .then next

    it 'pass multiple options', (next) ->
      mecano
      .call {test1: true}, {test2: true}, (options, next) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
        next()
      .then next
    
    it 'string requires a module', (next) ->
      logs = []
      mecano
      .on 'text', (l) -> logs.push l
      .call who: 'us', 'test/resources/module_async'
      .then (err) ->
        logs[0].message.should.eql 'Hello us' unless err
        next err

  describe 'async nested', ->

    it 'in a user callback', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
        , next
      .then (err, status) ->
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then with changes', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.true()
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then without changes', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
          if_exists: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'pass user arguments', (next) ->
      callback_called = false
      m = mecano
      .call (options, next) ->
        setImmediate ->
          next null, true, 'argument'
      , (err, status, argument) ->
        callback_called = true
        status.should.be.true()
        argument.should.equal 'argument'
      .then (err, status) ->
        callback_called.should.be.true() unless err
        status.should.be.true() unless err
        next err

        
