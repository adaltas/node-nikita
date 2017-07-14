
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api callback', ->

  scratch = test.scratch @

  it 'call callback multiple times for array of options', ->
    callbacks = []
    nikita
    .call [
      handler: -> # do sth
    ,
      handler: (_, callback) -> callback null, true
    ], (err, status) ->
      callbacks.push [err, status]
    .call ->
      callbacks.should.eql [
        [undefined, false]
        [undefined, true]
      ]
    .promise()

  it 'register actions in callback', ->
    msgs = []
    n = nikita log: (msg) -> msgs.push msg if /\/file_\d/.test msg
    n
    .file
      target: "#{scratch}/a_file"
      content: 'abc'
    , (err, written) ->
      return next err if err
      n.file
        target: "#{scratch}/a_file"
        content: 'def'
        append: true
      , (err, written) ->
        # ok
    .file
      target: "#{scratch}/a_file"
      content: 'hij'
      append: true
    .file.assert
      target: "#{scratch}/a_file"
      content: 'abcdefhij'
    .promise()
        
  describe 'error', ->

    it 'without parent', ->
      nikita()
      .file
        target: "#{scratch}/a_file"
        content: 'abc'
      , (err, written) ->
        throw Error 'Catchme'
      .call ->
        throw Error "Dont come here"
      .then (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'inside sync call', ->
      nikita
      .call () ->
        @call (->), ->
          throw Error 'Catchme'
      .then (err) ->
        err.message.should.eql 'Catchme'
      .promise()

    it 'inside async call', ->
      nikita
      .call (_, callback) ->
        @call (->), ->
          throw Error 'Catchme'
        @then callback
      .then (err) ->
        err.message.should.eql 'Catchme'
      .promise()
      
