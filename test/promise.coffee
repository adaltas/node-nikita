
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise', ->

  scratch = test.scratch @

  describe 'object', ->

    it 'works', (next) ->
      mecano
      .write
        destination: "#{scratch}/file_1"
        content: 'abc'
      .write
        destination: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        fs.readFile "#{scratch}/file_1", 'utf8', (err, content) ->
          content.should.eql 'abcdef'
          next()

  describe 'function', ->

    it 'works', (next) ->
      mecano({})
      .write
        destination: "#{scratch}/file_1"
        content: 'abc'
      .write
        destination: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        fs.readFile "#{scratch}/file_1", 'utf8', (err, content) ->
          content.should.eql 'abcdef'
          next()

    it 'pass global options', (next) ->
      logs = []
      log = (msg) -> logs.push msg
      mecano log: log
      .write
        destination: "#{scratch}/file_1"
        content: 'abc'
      .write
        destination: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        logs.length.should.be.above 1
        next()

  describe 'error', ->

    it 'catch err', (next) ->
      mecano
      .chmod
        destination: "#{scratch}/doesnt_exist"
      # todo: add another action to make sure it isnt called
      .then (err, changed) ->
        err.message.should.eql "Missing option 'mode'"
        next()

    it 'catch err in callback', (next) ->
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

    it 'continue if callback return true', (next) ->
      called = false
      mecano
      .chmod
        destination: "#{scratch}/doesnt_exist"
      , (err) ->
        err.message.should.eql "Missing option 'mode'"
        true
      .write
        content: 'hello'
        destination: "#{scratch}/exist"
      , (err, written) ->
        called = true if written
      .then (err, changed) ->
        called.should.be.True
        next err
        






