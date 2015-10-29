
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api stack', ->

  scratch = test.scratch @

  it 'sync handler register actions', (next) ->
    msgs = []
    m = mecano log: (log) -> msgs.push log.message
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
    m = mecano log: (log) -> msgs.push log.message
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
    m = mecano log: (log) -> msgs.push log.message
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
    m = mecano log: (log) -> msgs.push log.message if /\/file_\d/.test log.message
    m
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
    .write
      destination: "#{scratch}/file_2"
      content: 'def'
    .then (err, changed) ->
      return next err if err
      m
      .write
        destination: "#{scratch}/file_3"
        content: 'hij'
      .then (err, changed) ->
        return next err if err
        msgs.length.should.eql 3
        next()

  it 'clean stack with callback', (next) ->
    msgs = []
    m = mecano log: (log) -> msgs.push log.message if /\/file_\d/.test log.message
    m
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
    .write
      destination: "#{scratch}/file_2"
      content: 'def'
    , (err, changed) ->
      return next err if err
      m
      .write
        destination: "#{scratch}/file_3"
        content: 'hij'
      .then (err, changed) ->
        return next err if err
        msgs.length.should.eql 3
        next()

  describe 'error', ->

    it 'catch err', (next) ->
      mecano
      .chmod
        destination: "#{scratch}/doesnt_exist"
      .then (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
      .chmod
        mode: 0o0644
      .then (err, changed) ->
        err.message.should.eql "Missing destination: undefined"
      .then next

    it 'catch err without then', (next) ->
      m = mecano()
      m.chmod
        destination: "#{scratch}/doesnt_exist"
      , (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
        # There are multiple possibilities
        m.chmod
          mode: 0o0644
        .then (err, changed) ->
          err.message.should.eql "Missing destination: undefined"
        .then next

    it 'catch err thrown callback', (next) ->
      mecano
      .write
        content: 'hello'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        return next err if err
        throw Error 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()
