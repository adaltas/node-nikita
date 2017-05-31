
fs = require 'fs'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.cli', ->
  
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
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
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
      
  they 'print status', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data: data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', (_, callback) -> callback null, true
    .call header: 'c', shy: true, (_, callback) -> callback null, true
    .call header: 'd', (_, callback) -> callback new Error 'ok', false
    .then (err, status) ->
      data.should.eql [
        'localhost   a   -\n'
        'localhost   b   +\n'
        'localhost   c   -\n'
        'localhost   d   x\n'
      ]
      next()
      
  they 'bypass disabled and false conditionnal', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data: data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', disabled: true, (_, callback) -> callback null, true
    .call header: 'c', if: false, (_, callback) -> callback null, true
    .call header: 'd', (_, callback) -> callback null, true
    .then (err, status) ->
      data.should.eql [
        'localhost   a   -\n'
        'localhost   d   +\n'
      ]
      next()
      
  they 'option depth', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
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
      
  they 'option divider', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
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
      
  they 'option pad', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli pad: {host: 14, header: 18}, stream: new MyWritable data: data
    .call header: 'h1', (options) ->
      @call header: 'h2a', (options) ->
      @call header: 'h2b', (options) ->
        @call header: 'h3', (options) ->
    .then (err, status) ->
      return next err if err
      data.should.eql [
        'localhost      h1 : h2a           -\n'
        'localhost      h1 : h2b : h3      -\n'
        'localhost      h1 : h2b           -\n'
        'localhost      h1                 -\n'
      ]
      next()
      
  they 'option colors', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: time: false
    .log.cli colors: true, stream: new MyWritable data: data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', (_, callback) -> callback null, true
    .call header: 'c', (_, callback) -> callback new Error 'ok', false
    .then (err, status) ->
      data.should.eql [
        '\u001b[36m\u001b[2mlocalhost\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36m\u001b[2ma\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36m-\u001b[39m\n'
        '\u001b[36m\u001b[2mlocalhost\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36m\u001b[2mb\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36m+\u001b[39m\n'
        '\u001b[36m\u001b[2mlocalhost\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36m\u001b[2mc\u001b[22m\u001b[39m\u001b[36m\u001b[2m   \u001b[22m\u001b[39m\u001b[36mx\u001b[39m\n'
      ]
      next()
  
  they 'option time', (ssh, next) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false
    .log.cli stream: new MyWritable data: data
    .call header: 'h1', (->)
    .wait 200
    .then (err, status) ->
      return next err if err
      data[0].should.match /localhost   h1   -  \dms\n/
      next()
      
  
