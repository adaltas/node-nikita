
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
        @call header: 'h3', (options, callback) ->
          callback null, true
    .wait 200
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost   h1 : h2a   -\n'
        'localhost   h1 : h2b : h3   +\n'
        'localhost   h1 : h2b   +\n'
        'localhost   h1   +\n'
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
        'localhost   h1 : h2a   -\n'
        'localhost   h1 : h2b   -\n'
        'localhost   h1   -\n'
      ]
      next()
      
  they 'options divider', (ssh, next) ->
    data = []
    mecano
      ssh: ssh
    .log.cli divider: ' # ', stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost   h1 # h2a   -\n'
        'localhost   h1 # h2b # h3   -\n'
        'localhost   h1 # h2b   -\n'
        'localhost   h1   -\n'
      ]
      next()
      
  they 'options pad', (ssh, next) ->
    data = []
    mecano
      ssh: ssh
    .log.cli pad: {host: 14, header: 18}, stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost     h1 : h2a          -\n'
        'localhost     h1 : h2b : h3     -\n'
        'localhost     h1 : h2b          -\n'
        'localhost     h1                -\n'
      ]
      next()
  
