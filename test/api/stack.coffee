
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api stack', ->

  scratch = test.scratch @

  it 'sync handler register actions', (next) ->
    msgs = []
    m = mecano()
    m.on 'text', (log) -> msgs.push log.message
    m.call (options) ->
      options.log 'a1'
      m.call (options) ->
        options.log 'c'
        m.call (options) ->
          options.log 'd'
      m.call (options) ->
        options.log 'e'
      options.log 'b'
    , (err, status) ->
      msgs.push 'a2'
    m.then (err) ->
      msgs.should.eql ['a1', 'b', 'c', 'd', 'e', 'a2']
      next err

  it 'async handler register actions and callback async', (next) ->
    msgs = []
    m = mecano()
    m.on 'text', (log) -> msgs.push log.message
    m.call (options, next) ->
      options.log 'a'
      m.call (options, next) ->
        options.log 'c'
        setImmediate next
      m.call (options, next) ->
        options.log 'd'
        setImmediate next
      setImmediate next
      options.log 'b'
    m.then ->
      msgs.should.eql ['a', 'b', 'c', 'd']
      next()

  it 'async handler register actions and callback sync', (next) ->
    msgs = []
    m = mecano()
    m.on 'text', (log) -> msgs.push log.message
    m.call (options, next) ->
      options.log 'a'
      m.call (options, next) ->
        options.log 'c'
        next()
      m.call (options, next) ->
        options.log 'd'
        next()
      next()
      options.log 'b'
    m.then ->
      msgs.should.eql ['a', 'b', 'c', 'd']
      next()


  it 'clean stack with then', (next) ->
    msgs = []
    m = mecano()
    m.on 'text', (log) -> msgs.push log.message
    m
    .call (options, callback) ->
      options.log 'a'
      callback()
    .call (options, callback) ->
      options.log 'b'
      callback()
    .then (err, changed) ->
      return next err if err
      m
      .call (options, callback) ->
        options.log 'c'
        callback()
      .then (err, changed) ->
        msgs.should.eql ['a', 'b', 'c'] unless err
        next err

  it 'clean stack with callback', (next) ->
    msgs = []
    m = mecano()
    m.on 'text', (log) -> msgs.push log.message
    m.call (options, callback) ->
      options.log 'a'
      callback()
    m.call (options, callback) ->
      options.log 'b'
      callback()
    , (err, changed) ->
      return next err if err
      m.call (options, callback) ->
        options.log 'c'
        callback()
      m.then (err, changed) ->
        msgs.should.eql ['a', 'b', 'c'] unless err
        next err
  
  it 'can finish and resume', (next) ->
    m = mecano
    .call(->)
    .then (err, status) ->
      process.nextTick =>
        # At this point internal stack is empty
        # let's fill it again
        @call ->
        @then next
      , 1000

  describe 'error', ->

    it 'catch err', (next) ->
      mecano
      .system.chmod
        target: "#{scratch}/doesnt_exist"
      .then (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
      .system.chmod
        mode: 0o0644
      .then (err, changed) ->
        err.message.should.eql "Missing target: undefined"
      .then next

    it 'catch err without then', (next) ->
      mecano()
      .system.chmod
        target: "#{scratch}/doesnt_exist"
        relax: true
      , (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
      # There are multiple possibilities
      .system.chmod
        mode: 0o0644
        relax: true
      , (err, changed) ->
        err.message.should.eql "Missing target: undefined"
      .then next

    it 'catch err thrown callback', (next) ->
      mecano
      .file
        content: 'hello'
        target: "#{scratch}/a_file"
      , (err, written) ->
        throw new Error 'Catchme' unless err
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'catch err in child', (next) ->
      mecano
      .call ->
        @call ->
          throw Error 'Catchme'
      .then (err) ->
        err.message.should.eql "Catchme"
        next()
