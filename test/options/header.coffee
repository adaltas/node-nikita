
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options header', ->

  scratch = test.scratch @
  
  it.only 'print value', (next) ->
    headers = []
    mecano
    .on 'header', (log) ->
      headers.push message: log.message, depth: log.depth, headers: log.headers, header_depth: log.header_depth, total_depth: log.total_depth
    .call
      header: 'h1 call'
      handler: ->
        @call
          header: 'h2 call'
          handler: (_, callback) -> callback()
        @touch 
          header: 'h2 touch'
          destination: "#{scratch}/file_h2"
    .touch
      header: 'h1 touch'
      destination: "#{scratch}/file_h1"
    .then (err) ->
      return next err if err
      headers.should.eql [
        { message: 'h1 call', depth: 1, headers: ['h1 call'], header_depth: 1, total_depth: 0 }
        { message: 'h2 call', depth: 2, headers: ['h1 call', 'h2 call'], header_depth: 2, total_depth: 1 }
        { message: 'h2 touch', depth: 2, headers: ['h1 call', 'h2 touch'], header_depth: 2, total_depth: 1 }
        { message: 'h1 touch', depth: 1, headers: ['h1 touch'], header_depth: 1, total_depth: 0 }
      ]
      next()
    
