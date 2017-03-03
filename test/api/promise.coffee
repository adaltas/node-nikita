
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api promise', ->

  scratch = test.scratch @

  describe 'object', ->

    it 'works', (next) ->
      nikita
      .file
        target: "#{scratch}/file_1"
        content: 'abc'
      .file
        target: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        fs.readFile "#{scratch}/file_1", 'utf8', (err, content) ->
          content.should.eql 'abcdef'
          next()

  describe 'function', ->

    it 'works', (next) ->
      nikita({})
      .file
        target: "#{scratch}/file_1"
        content: 'abc'
      .file
        target: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        fs.readFile "#{scratch}/file_1", 'utf8', (err, content) ->
          content.should.eql 'abcdef'
          next()

    it 'pass global options', (next) ->
      logs = []
      nikita
      .on 'text', (log) -> logs.push log
      .file
        target: "#{scratch}/file_1"
        content: 'abc'
      .file
        target: "#{scratch}/file_1"
        content: 'def'
        append: true
      .then (err, changed) ->
        return next err if err
        logs.length.should.be.above 1
        next()

        
