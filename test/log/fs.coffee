
fs = require 'fs'
path = require 'path'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.fs', ->

  scratch = test.scratch @

  they 'requires option "serializer"', (ssh) ->
    nikita ssh: ssh
    .log.fs basedir: scratch
    .next (err) ->
      err.message.should.eql 'Missing option: serializer'
    .promise()

  they 'serializer can be empty', (ssh) ->
    nikita
      ssh: ssh
    .log.fs
      basedir: scratch
      serializer: {}
    .call (options) ->
      @log message: 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: ''
      log: false
    .assert status: false
    .promise()

  they 'default options', (ssh) ->
    nikita
      ssh: ssh
      log_fs: basedir: scratch, serializer: text: (log) -> "#{log.message}\n"
    .log.fs()
    .call (options) ->
      @log message: 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: /^ok\n/
      log: false
    .promise()

  describe 'archive', ->

    they 'archive default directory name', (ssh) ->
      nikita
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        @log message: 'ok'
      .call ->
        now = new Date()
        dir = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2)
        @file.assert
          source: "#{scratch}/#{dir}/localhost.log"
          content: /ok/m
          log: false
      .assert status: false
      .promise()

    they 'latest', (ssh) ->
      nikita
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        @log message: 'ok'
      .call (_, callback) ->
        @fs.lstat "#{scratch}/latest", (err, stats) ->
          stats.isSymbolicLink().should.be.true() unless err
          callback err
      .file.assert
        source: "#{scratch}/latest/localhost.log"
        content: /ok/m
        log: false
      .assert status: false
      .promise()
