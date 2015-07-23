
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'promise stack', ->

  scratch = test.scratch @

  it 'clean stack with then', (next) ->
    msgs = []
    m = mecano log: (msg) -> msgs.push msg if /\/file_\d/.test msg
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
    m = mecano log: (msg) -> msgs.push msg if /\/file_\d/.test msg
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






