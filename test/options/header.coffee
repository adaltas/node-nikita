
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "header"', ->

  scratch = test.scratch @
  
  it 'print value', ->
    headers = []
    nikita
    .on 'header', (log) ->
      headers.push message: log.message, headers: log.headers, depth: log.depth
    .call header: '1', ->
      @call header: '1.1', ->
        @call header: '1.1.1', (->)
      @file.touch header: '1.2', target: "#{scratch}/file_h2"
    .file.touch
      header: '2'
      target: "#{scratch}/file_h1"
    .call ->
      headers.should.eql [
        { message: '1', headers: ['1'], depth: 0 }
        { message: '1.1', headers: ['1', '1.1'], depth: 1 }
        { message: '1.1.1', headers: ['1', '1.1', '1.1.1'], depth: 2 }
        { message: '1.2', headers: ['1', '1.2'], depth: 1 }
        { message: '2', headers: ['2'], depth: 0 }
      ]
    .promise()
