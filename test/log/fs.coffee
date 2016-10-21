
fs = require 'fs'
path = require 'path'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log fs', ->

  scratch = test.scratch @

  they 'requires option "serializer"', (ssh, next) ->
    mecano ssh: ssh
    .log.fs basedir: scratch
    .then (err, status) ->
      err.message.should.eql 'Missing option: serializer'
      next()

  they 'in base directory', (ssh, next) ->
    mecano
      ssh: ssh
    .log.fs
      basedir: scratch
      serializer: {}
    .call (options) ->
      options.log message: 'ok'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      fs.exists "#{scratch}/localhost.log", (exists) ->
        exists.should.be.true()
        next()

  describe 'archive', ->

    they 'archive default directory name', (ssh, next) ->
      mecano
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        options.log message: 'ok'
      .then (err, status) ->
        return next err if err
        now = new Date()
        dir = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2)
        fs.stat "#{scratch}/#{dir}", (err, stats) ->
          return err if err
          stats.isDirectory().should.be.true()
          fs.readFile "#{scratch}/#{dir}/localhost.log", 'utf8', (err, content) ->
            content = content.split if ssh or path.posix then '\n' else '\r\n'
            content.should.containEql 'ok' unless err
            next err

    they 'latest', (ssh, next) ->
      mecano
        ssh: ssh
      .log.fs
        basedir: scratch
        serializer: text: (log) -> "#{log.message}\n"
        archive: true
      .call (options) ->
        options.log message: 'ok'
      .then (err, status) ->
        return next err if err
        status.should.be.false()
        fs.lstat "#{scratch}/latest", (err, stats) ->
          return err if err
          stats.isSymbolicLink().should.be.true()
          fs.readFile "#{scratch}/latest/localhost.log", 'utf8', (err, content) ->
            content = content.split if ssh or path.posix then '\n' else '\r\n'
            content.should.containEql 'ok' unless err
            next err
