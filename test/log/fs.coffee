
fs = require 'fs'
path = require 'path'
should = require 'should'
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log.fs', ->

  scratch = test.scratch @

  they 'requires option "serializer"', (ssh, next) ->
    nikita ssh: ssh
    .log.fs basedir: scratch
    .then (err, status) ->
      err.message.should.eql 'Missing option: serializer'
      next()

  they 'serializer can be empty', (ssh, next) ->
    nikita
      ssh: ssh
    .log.fs
      basedir: scratch
      serializer: {}
    .call (options) ->
      options.log message: 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: ''
      log: false
    .assert status: false
    .then next

  they 'default options', (ssh, next) ->
    nikita
      ssh: ssh
      log_fs: basedir: scratch, serializer: text: (log) -> "#{log.message}\n"
    .log.fs()
    .call (options) ->
      options.log message: 'ok'
    .file.assert
      source: "#{scratch}/localhost.log"
      content: 'ok\n'
      log: false
    .then next

  describe 'archive', ->

    they 'archive default directory name', (ssh, next) ->
      nikita
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        options.log message: 'ok'
      .call ->
        now = new Date()
        dir = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2)
        @file.assert
          source: "#{scratch}/#{dir}/localhost.log"
          content: /ok/m
          log: false
      .assert status: false
      .then next

    they 'latest', (ssh, next) ->
      nikita
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        options.log message: 'ok'
      .call (_, callback) ->
        fs.lstat "#{scratch}/latest", (err, stats) ->
          stats.isSymbolicLink().should.be.true() unless err
          callback err
      .file.assert
        source: "#{scratch}/latest/localhost.log"
        content: /ok/m
        log: false
      .assert status: false
      .then next
