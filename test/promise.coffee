
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

    # it 'continue if callback return true', (next) ->
    #   called = false
    #   mecano
    #   .chmod
    #     destination: "#{scratch}/doesnt_exist"
    #   , (err) ->
    #     err.message.should.eql "Missing option 'mode'"
    #     true
    #   .write
    #     content: 'hello'
    #     destination: "#{scratch}/exist"
    #   , (err, written) ->
    #     called = true if written
    #   .then (err, changed) ->
    #     called.should.be.true()
    #     next err
        






