
nikita = require '../../src'
test = require '../test'
fs = require 'fs'
path = require 'path'

describe 'api call', ->

  scratch = test.scratch @

  describe 'api', ->

    it 'accept an array of handlers and a callback', (next) ->
      logs = []
      nikita
      .call [
        (options) -> logs.push 'a'
      ,
        (options, callback) -> logs.push('b'); callback()
      ], (err, status) ->
        logs.push 'c'
        status.should.be.false() unless err
      .call ->
        logs.should.eql ['a', 'c', 'b', 'c']
      .then next

    it 'string requires a module', (next) ->
      logs = []
      nikita
      .on 'text', (log) -> logs.push log.message
      .call who: 'sync', 'test/resources/module_sync'
      .call who: 'async', 'test/resources/module_async'
      .then (err) ->
        logs.should.eql ['Hello sync', 'Hello async'] unless err
        next err

    it 'string requires a module from process cwd', (next) ->
      cwd = null
      nikita
      .call -> cwd = process.cwd()
      .call -> process.chdir path.resolve __dirname, '../../'
      .call './src/core/ping', (err, status, message) ->
        message.should.eql 'pong' unless err
      .call -> process.chdir cwd
      .then next

    it 'string requires a module which export an object', (next) ->
      logs = []
      nikita
      .on 'text', (l) -> logs.push l.message
      .call who: 'us', 'test/resources/module_async_object'
      .then (err) ->
        logs[0].should.eql 'Hello us' unless err
        next err

    it 'accept a string and an handler', (next) ->
      nikita()
      .call 'gotit', handler: ( (options) -> options.argument.should.eql 'gotit' )
      .then next

  describe 'sync', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/file_a"
      , (err) ->
        touched++
      .call (options) ->
        called++
      .file.touch
        target: "#{scratch}/file_b"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'execute a callback', (next) ->
      called = 0
      nikita
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
      nikita
      .call test: true, (options) ->
        options.test.should.be.true()
      .then next

    it 'pass multiple options', (next) ->
      nikita
      .call {test1: true}, {test2: true}, (options) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
      .then next

  describe 'async', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          called++
          next()
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'execute a callback', (next) ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          next()
      , (err, status) ->
        called++ unless err
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'pass options', (next) ->
      nikita
      .call test: true, (options, next) ->
        options.test.should.be.true()
        next()
      .then next

    it 'pass multiple options', (next) ->
      nikita
      .call {test1: true}, {test2: true}, (options, next) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
        next()
      .then next

  describe 'async nested', ->

    it 'in a user callback', (next) ->
      m = nikita
      .call (options, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
        , next
      .then (err, status) ->
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then with changes', (next) ->
      m = nikita
      .call (options, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.true()
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then without changes', (next) ->
      m = nikita
      .call (options, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
          if_exists: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'pass user arguments', (next) ->
      callback_called = false
      m = nikita
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
