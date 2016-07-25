
fs = require 'fs'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log md', ->
  
  scratch = test.scratch @
  
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

  describe 'stdout', ->
    
    they 'in base directory', (ssh, next) ->
      m = mecano
        ssh: ssh
      .log.md basedir: scratch
      .call (options) ->
        options.log message: 'this is a one line output', type: 'stdout_stream'
        options.log message: null, type: 'stdout_stream'
      .then (err, status) ->
        return next err if err
        fs.readFile "#{scratch}/localhost.log", 'utf8', (err, content) ->
          content.should.eql '\n```stdout\nthis is a one line output\n```\n\n' unless err
          next err
      
