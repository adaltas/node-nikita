
fs = require 'fs'
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

Writable = require('stream').Writable
class MyWritable extends Writable
  constructor: (data) ->
    super()
    @data = data
  _write: (chunk, encoding, callback) ->
    @data.push chunk.toString()
    callback()

describe 'log.cli', ->
  
  they 'default options', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data
    .call header: 'h1', ->
      @call header: 'h2a', ->
      @call header: 'h2b', ->
        @call header: 'h3', ({}, callback) ->
          callback null, true
    .wait 200
    .call ->
      data.should.eql [
        'localhost   h1 : h2a   -\n'
        'localhost   h1 : h2b : h3   ✔\n'
        'localhost   h1 : h2b   ✔\n'
        'localhost   h1   ✔\n'
      ]
    .promise()
  
  they 'pass over actions without header', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data
    .call header: 'h1', ->
      @call header: 'h2a', ->
      @call  ->
        @call  ->
          @call header: 'h2b', ({}, callback) ->
            callback null, true
    .wait 200
    .call ->
      data.should.eql [
        'localhost   h1 : h2a   -\n'
        'localhost   h1 : h2b   ✔\n'
        'localhost   h1   ✔\n'
      ]
    .promise()

  they 'print status', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', (_, callback) -> callback null, true
    .call header: 'c', shy: true, (_, callback) -> callback null, true
    .call header: 'd', relax: true, (_, callback) -> callback new Error 'ok'
    .call ->
      data.should.eql [
        'localhost   a   -\n'
        'localhost   b   ✔\n'
        'localhost   c   -\n'
        'localhost   d   ✘\n'
      ]
    .promise()

  they 'bypass disabled and false conditionnal', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli stream: new MyWritable data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', disabled: true, (_, callback) -> callback null, true
    .call header: 'c', if: false, (_, callback) -> callback null, true
    .call header: 'd', (_, callback) -> callback null, true
    .call ->
      data.should.eql [
        'localhost   a   -\n'
        'localhost   d   ✔\n'
      ]
    .promise()

  they 'option depth', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli depth_max: 2, stream: new MyWritable data
    .call header: 'h1', ->
      @call header: 'h2a', ->
      @call header: 'h2b', ->
        @call header: 'h3', ->
    .call ->
      data.should.eql [
        'localhost   h1 : h2a   -\n'
        'localhost   h1 : h2b   -\n'
        'localhost   h1   -\n'
      ]
    .promise()

  they 'option divider', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli divider: ' # ', stream: new MyWritable data
    .call header: 'h1', ->
      @call header: 'h2a', ->
      @call header: 'h2b', ->
        @call header: 'h3', ->
    .call ->
      data.should.eql [
        'localhost   h1 # h2a   -\n'
        'localhost   h1 # h2b # h3   -\n'
        'localhost   h1 # h2b   -\n'
        'localhost   h1   -\n'
      ]
    .promise()

  they 'option pad', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false, time: false
    .log.cli pad: {host: 14, header: 18}, stream: new MyWritable data
    .call header: 'h1', ->
      @call header: 'h2a', ->
      @call header: 'h2b', ->
        @call header: 'h3', ->
    .call ->
      data.should.eql [
        'localhost      h1 : h2a           -\n'
        'localhost      h1 : h2b : h3      -\n'
        'localhost      h1 : h2b           -\n'
        'localhost      h1                 -\n'
      ]
    .promise()

  they 'option colors', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: time: false
    .log.cli colors: true, stream: new MyWritable data
    .call header: 'a', (_, callback) -> callback null, false
    .call header: 'b', (_, callback) -> callback null, true
    .call header: 'c', relax: true, (_, callback) -> callback new Error 'ok', false
    .call ->
      data.should.eql [
        '\u001b[36m\u001b[2mlocalhost   a   -\u001b[22m\u001b[39m\n'
        '\u001b[32mlocalhost   b   ✔\u001b[39m\n'
        '\u001b[31mlocalhost   c   ✘\u001b[39m\n'
      ]
    .promise()
  
  they 'option time', (ssh) ->
    data = []
    nikita
      ssh: ssh
      log_cli: colors: false
    .log.cli stream: new MyWritable data
    .call header: 'h1', (->)
    .wait 200
    .call ->
      data[0].should.match /localhost   h1   -  \dms\n/
    .promise()
