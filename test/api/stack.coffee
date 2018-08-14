
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api stack', ->

  scratch = test.scratch @

  it 'sync handler register actions', ->
    msgs = []
    n = nikita()
    n.on 'text', (log) -> msgs.push log.message
    n.call ->
      @log 'a1'
      n.call ->
        @log 'c'
        n.call ->
          @log 'd'
      n.call ->
        @log 'e'
      @log 'b'
    , (err, status) ->
      msgs.push 'a2'
    n.next (err) ->
      msgs.should.eql ['a1', 'b', 'c', 'd', 'e', 'a2']
    n.promise()

  it 'async handler register actions and callback async', ->
    msgs = []
    n = nikita()
    n.on 'text', (log) -> msgs.push log.message
    n.call ({}, next) ->
      @log 'a'
      n.call ({}, next) ->
        @log 'c'
        setImmediate next
      n.call ({}, next) ->
        @log 'd'
        setImmediate next
      setImmediate next
      @log 'b'
    n.call ->
      msgs.should.eql ['a', 'b', 'c', 'd']
    n.promise()

  it 'async handler register actions and callback sync', ->
    msgs = []
    n = nikita()
    n.on 'text', (log) -> msgs.push log.message
    n.call ({}, next) ->
      @log 'a'
      n.call ({}, next) ->
        @log 'c'
        next()
      n.call ({}, next) ->
        @log 'd'
        next()
      next()
      @log 'b'
    n.call ->
      msgs.should.eql ['a', 'b', 'c', 'd']
    n.promise()


  it 'clean stack with then', ->
    msgs = []
    n = nikita()
    n.on 'text', (log) -> msgs.push log.message
    n
    .call ({}, callback) ->
      @log 'a'
      callback()
    .call ({}, callback) ->
      @log 'b'
      callback()
    .next ->
      n
      .call ({}, callback) ->
        @log 'c'
        callback()
      .next (err, changed) ->
        msgs.should.eql ['a', 'b', 'c'] unless err
    .promise()

  it 'clean stack with callback', ->
    msgs = []
    n = nikita()
    n.on 'text', (log) -> msgs.push log.message
    n.call ({}, callback) ->
      @log 'a'
      callback()
    n.call ({}, callback) ->
      @log 'b'
      callback()
    , (err, changed) ->
      return next err if err
      n.call ({}, callback) ->
        @log 'c'
        callback()
      n.next (err, changed) ->
        msgs.should.eql ['a', 'b', 'c'] unless err
    .promise()
  
  it 'can finish and resume', (next) ->
    setImmediate ->
      nikita
      .call(->)
      .next (err, status) ->
        process.nextTick =>
          # At this point internal stack is empty
          # let's fill it again
          @call ->
          @next next
        , 1000

  describe 'error', ->

    it 'catch err', ->
      nikita
      .system.chmod
        target: "#{scratch}/doesnt_exist"
      .next (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
      .system.chmod
        mode: 0o0644
      .next (err) ->
        err.message.should.eql "Missing target: undefined"
      .promise()

    it 'catch err without then', ->
      nikita()
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
      .promise()

    it 'catch err thrown callback',  ->
      nikita
      .file
        content: 'hello'
        target: "#{scratch}/a_file"
      , (err, written) ->
        throw new Error 'Catchme' unless err
      .next (err, changed) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'catch err in child', ->
      nikita
      .call ->
        @call ->
          throw Error 'Catchme'
      .next (err) ->
        err.message.should.eql "Catchme"
      .promise()
