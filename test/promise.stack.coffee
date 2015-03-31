
mecano = require '../src'
test = require './test'

describe 'promise stack', ->

  scratch = test.scratch @

  it 'clean stack with then', (next) ->
    console.log '================='
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
      console.log '-----------------'
      m
      .write
        destination: "#{scratch}/file_3"
        content: 'hij'
      .then (err, changed) ->
        return next err if err
        console.log '----------------- done'
        msgs.length.should.eql 3
        next()

  it 'clean stack with callback', (next) ->
    console.log '================='
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
        console.log msgs
        msgs.length.should.eql 3
        next()
