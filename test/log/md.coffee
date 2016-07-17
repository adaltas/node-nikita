
fs = require 'fs'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log md', ->
  
  scratch = test.scratch @
  
  they 'in base directory', (ssh, next) ->
    mecano
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log message: 'ok'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      fs.exists "#{scratch}/localhost.log", (exists) ->
        exists.should.be.true()
        next()
  
  they 'write string', (ssh, next) ->
    mecano
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log 'ok'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      setTimeout ->
        fs.readFile "#{scratch}/localhost.log", 'utf8', (err, content) ->
          content.should.eql "ok\n" unless err
          next err
      , 100
  
  they 'write message', (ssh, next) ->
    mecano
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log message: 'ok'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      setTimeout ->
        fs.readFile "#{scratch}/localhost.log", 'utf8', (err, content) ->
          content.should.eql "ok\n" unless err
          next err
      , 100
  
  they 'write message and module', (ssh, next) ->
    mecano
      ssh: ssh
    .log.md basedir: scratch
    .call (options) ->
      options.log message: 'ok', module: 'mecano/test/log/md'
    .then (err, status) ->
      return next err if err
      status.should.be.false()
      setTimeout ->
        fs.readFile "#{scratch}/localhost.log", 'utf8', (err, content) ->
          content.should.eql "ok (INFO, written by mecano/test/log/md)\n" unless err
          next err
      , 100
  
  describe 'archive', ->
  
    they 'in base directory', (ssh, next) ->
      mecano
        ssh: ssh
      .log.md basedir: scratch, archive: true
      .call (options) ->
        options.log message: 'ok'
      .then (err, status) ->
        return next err if err
        status.should.be.false()
        fs.lstat "#{scratch}/latest", (err, stats) ->
          return err if err
          stats.isSymbolicLink().should.be.true()
          fs.readFile "#{scratch}/latest/localhost.log", 'utf8', (err, content) ->
            content.should.eql "ok\n" unless err
            next err
