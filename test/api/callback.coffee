
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api callback', ->

  scratch = test.scratch @

  it 'call callback multiple times if options an array', ->
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

  it 'call actions in callback', ->
    msgs = []
    n = nikita log: (msg) -> msgs.push msg if /\/file_\d/.test msg
    n
    .file
      target: "#{scratch}/a_file"
      content: 'abc'
    , (err, written) ->
      throw err if err
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
    
    describe 'next', ->

      it 'without parent', ->
        nikita()
        .file
          target: "#{scratch}/a_file"
          content: 'abc'
        , (err, written) ->
          throw Error 'Catchme'
        .call ->
          throw Error "Dont come here"
        .next (err) ->
          err.message.should.eql 'Catchme'
        .promise()

      it 'inside sync call', ->
        nikita
        .call () ->
          @call (->), ->
            throw Error 'Catchme'
          @call ->
            throw Error 'Dont come here'
        .call ->
          throw Error 'Dont come here'
        .next (err) ->
          err.message.should.eql 'Catchme'
        .promise()

      it 'inside async call', ->
        nikita
        .call (_, callback) ->
          @call (->), ->
            throw Error 'Catchme'
          @call ->
            throw Error 'Dont come here'
          @next callback
        .next (err) ->
          err.message.should.eql 'Catchme'
        .promise()
          
    describe 'promise', ->

      it 'without parent', ->
        nikita()
        .file
          target: "#{scratch}/a_file"
          content: 'abc'
        , (err) ->
          throw Error 'Catchme'
        .call ->
          throw Error 'Dont come here'
        .promise()
        .then ->
          throw Error 'Dont come here'
        .catch (err) ->
          err.message.should.eql 'Catchme'
        .then()

      it 'inside sync call', ->
        nikita
        .call () ->
          @call (->), ->
            throw Error 'Catchme'
          @call ->
            throw Error 'Dont come here'
        .call ->
          throw Error 'Dont come here'
        .promise()
        .then ->
          throw Error 'Dont come here'
        .catch (err) ->
          err.message.should.eql 'Catchme'
        .then()

      it 'inside sync call', ->
        nikita
        .call (_, callback) ->
          @call (->), ->
            throw Error 'Catchme'
          @call ->
            throw Error 'Dont come here'
          @next callback
        .call ->
          throw Error 'Dont come here'
        .promise()
        .then ->
          throw Error 'Dont come here'
        .catch (err) ->
          err.message.should.eql 'Catchme'
        .then()
