
nikita = require '../../src'
test = require '../test'
fs = require 'fs'
path = require 'path'

describe 'api call', ->

  scratch = test.scratch @

  describe 'api', ->

    it 'accept an array of handlers and a callback', ->
      logs = []
      nikita
      .call [
        (options) -> logs.push 'a'
      ,
        (options, callback) -> logs.push('b'); callback()
      ], (err, {status}) ->
        logs.push 'c'
        status.should.be.false() unless err
      .call ->
        logs.should.eql ['a', 'c', 'b', 'c']
      .promise()

    it 'string requires a module', ->
      logs = []
      nikita
      .on 'text', (log) -> logs.push log.message
      .call who: 'sync', 'test/resources/module_sync'
      .call who: 'async', 'test/resources/module_async'
      .call ->
        logs.should.eql ['Hello sync', 'Hello async']
      .promise()

    it 'string requires a module from process cwd', ->
      cwd = process.cwd()
      process.chdir path.resolve __dirname, "#{scratch}"
      nikita
      .file
        target: "#{scratch}/a_dir/ping.coffee"
        content: 'module.exports = (_, callback) -> callback null, status: true, message: "pong"'
      .call ->
        @call './a_dir/ping', (err, {status, message}) ->
          message.should.eql 'pong' unless err
      .call -> process.chdir cwd
      .promise()

    it 'string requires a module which export an object', ->
      logs = []
      nikita
      .on 'text', (l) -> logs.push l.message
      .call who: 'us', 'test/resources/module_async_object'
      .call ->
        logs[0].should.eql 'Hello us'
      .promise()

    it.skip 'accept a string and an handler', ->
      # No longer supported with the current implementation
      # Was working before but it seems really awkward as it
      # would imply having different behavior when a handler is provided
      # as a function or as a value assiated to the handler key
      nikita()
      .call 'gotit',
        handler: (options) -> options.argument.should.eql 'gotit'
      .promise()

  describe 'sync', ->

    it 'execute a handler', ->
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
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'execute a callback', ->
      called = 0
      nikita
      # 1st arg options with handler, 2nd arg a callback
      .call handler: (->), (err, {status}) ->
        status.should.be.false() unless err
        called++ unless err
      # 1st arg handler, 2nd arg a callback
      .call (->), (err, {status}) ->
        status.should.be.false() unless err
        called++ unless err
      .call ->
        called.should.eql 2
      .promise()

    it 'pass options', ->
      nikita
      .call test: true, (options) ->
        options.test.should.be.true()
      .promise()

    it 'pass multiple options', ->
      nikita
      .call {test1: true}, {test2: true}, (options) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
      .promise()

  describe 'async', ->

    it 'execute a handler', ->
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
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'execute a callback', ->
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
      , (err) ->
        called++ unless err
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'pass options', ->
      nikita
      .call test: true, (options, next) ->
        options.test.should.be.true()
        next()
      .promise()

    it 'pass multiple options', ->
      nikita
      .call {test1: true}, {test2: true}, (options, next) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
        next()
      .promise()

  describe 'async nested', ->

    it 'in a user callback', ->
      nikita
      .call (options, next) ->
        @file
          target: "#{scratch}/a_file"
          content: 'ok'
        , next
      .assert
        status: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'ok'
      .promise()

    it 'in then with changes', ->
      nikita
      .call (options, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
        .next next
      .assert
        status: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'ok'
      .promise()

    it 'in then without changes', ->
      nikita
      .call (options, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
          if_exists: "#{scratch}/a_file"
        .next next
      .assert
        status: false
      .promise()

    it 'pass user arguments', ->
      callback_called = false
      nikita
      .call (options, next) ->
        setImmediate ->
          next null, status: true, argument: 'argument'
      , (err, {status, argument}) ->
        callback_called = true
        status.should.be.true()
        argument.should.equal 'argument'
      .assert
        status: true
      .call ->
        callback_called.should.be.true()
      .promise()
