
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "header"', ->

  scratch = test.scratch @
  
  it 'print value', ->
    headers = []
    nikita
    .on 'header', (log) ->
      headers.push message: log.message, depth: log.depth, headers: log.headers, header_depth: log.header_depth, total_depth: log.total_depth
    .call header: 'h1 call', ->
      @call header: 'h2 call', (_, callback) -> callback()
      @file.touch header: 'h2 touch', target: "#{scratch}/file_h2"
    .file.touch
      header: 'h1 touch'
      target: "#{scratch}/file_h1"
    .call ->
      headers.should.eql [
        { message: 'h1 call', depth: 1, headers: ['h1 call'], header_depth: 1, total_depth: 0 }
        { message: 'h2 call', depth: 2, headers: ['h1 call', 'h2 call'], header_depth: 2, total_depth: 1 }
        { message: 'h2 touch', depth: 2, headers: ['h1 call', 'h2 touch'], header_depth: 2, total_depth: 1 }
        { message: 'h1 touch', depth: 1, headers: ['h1 touch'], header_depth: 1, total_depth: 0 }
      ]
    .promise()

  it 'decrement when option is reset', ->
    headers = []
    nikita
    .on 'header', (log) ->
      headers.push depth: log.depth, header_depth: log.header_depth, headers: log.headers
    .call header: 'h1a', (options) ->
      options.header = null
      @call options, header: 'h2a', (_, callback) -> callback()
      @call options, header: 'h2b', (options, callback) ->
        options.header = null
        @call options, header: 'h3a', (_, callback) -> callback()
        @next callback
      @call options, header: 'h2c', (_, callback) -> callback()
    .file.touch
      header: 'h1b'
      target: "#{scratch}/file_h1"
    .next (err) ->
      # console.log err, headers
      # return next err if err
      headers.should.eql [
        { depth: 1, header_depth: 1, headers: ['h1a'] }
        { depth: 2, header_depth: 2, headers: ['h1a', 'h2a'] }
        { depth: 2, header_depth: 2, headers: ['h1a', 'h2b'] }
        { depth: 3, header_depth: 3, headers: ['h1a', 'h2b', 'h3a'] }
        { depth: 2, header_depth: 2, headers: ['h1a', 'h2c'] }
        { depth: 1, header_depth: 1, headers: ['h1b'] }
      ]
    .promise()
