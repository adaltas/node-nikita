
fs = require 'fs'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log cli', ->
  
  scratch = test.scratch @
  
  Writable = require('stream').Writable;
  class MyWritable extends Writable
    constructor: (@options) ->
      super @options
    _write: (chunk, encoding, callback) ->
      @options.data.push chunk.toString()
      callback()
  
  they 'default options', (ssh, next) ->
    data = []
    mecano
      ssh: ssh
    .log.cli stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .wait 200
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost  h1'
        'localhost  h1 # h2a'
        'localhost  h1 # h2b'
        'localhost  h1 # h2b # h3'
      ]
      next()
      
  they 'option depth', (ssh, next) ->
    data = []
    mecano
      ssh: ssh
    .log.cli depth: 2, stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost  h1'
        'localhost  h1 # h2a'
        'localhost  h1 # h2b'
      ]
      next()
      
  they 'options separator', (ssh, next) ->
    data = []
    mecano
      ssh: ssh
    .log.cli separator: ' : ', stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost  h1'
        'localhost  h1 : h2a'
        'localhost  h1 : h2b'
        'localhost  h1 : h2b : h3'
      ]
      next()
  
