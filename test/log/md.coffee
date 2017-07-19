
fs = require 'fs'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.md', ->
  
  scratch = test.scratch @
  
  they 'write string', (ssh) ->
    nikita
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: "ok\n"
      log: false
    .assert
      status: false
    .promise()
  
  they 'write message', (ssh) ->
    nikita
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log message: 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: "ok\n"
      log: false
    .assert
      status: false
    .promise()
  
  they 'write message and module', (ssh) ->
    nikita
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log message: 'ok', module: 'nikita/test/log/md'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: "ok (INFO, written by nikita/test/log/md)\n"
      log: false
    .assert
      status: false
    .promise()
    
  they 'default options', (ssh) ->
    nikita
      ssh: ssh
      log_md: basedir: scratch
    .log.md()
    .call (options) ->
      options.log 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: "ok\n"
      log: false
    .assert
      status: false
    .promise()

  describe 'stdout', ->
    
    they 'in base directory', (ssh) ->
      m = nikita
        ssh: ssh
      .log.md basedir: scratch
      .call (options) ->
        options.log message: 'this is a one line output', type: 'stdout_stream'
        options.log message: null, type: 'stdout_stream'
      .file.assert
        source: "#{scratch}/localhost.log"
        content: '\n```stdout\nthis is a one line output\n```\n\n'
        log: false
      .assert
        status: false
      .promise()
