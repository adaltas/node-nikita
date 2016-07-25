
fs = require 'fs'
should = require 'should'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'log', ->
  
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

    they 'in base directory', (ssh, next) ->
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
            content.should.eql "ok\n" unless err
            next err
    
