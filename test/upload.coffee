
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
they = require 'superexec/lib/they'
misc = require '../lib/misc'
connect = require 'superexec/lib/connect'

describe 'upload', ->

  scratch = test.scratch @

  it 'check md5 for binary file', (next) ->
    @timeout 0
    mecano.execute
      cmd: "tar czf #{scratch}/source.tar.gz -C #{__dirname}/../ ."
    , (err, executed) ->
      return next err if err
      mecano.execute
        cmd: "openssl md5 #{scratch}/source.tar.gz"
      , (err, executed, srcsum) ->
        return next err if err
        srcsum = /[ ](.*)$/.exec(srcsum.trim())[1]
        connect host: 'localhost', (err, ssh) ->
          return next err if err
          # Check valid file
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
            md5: srcsum
          , (err, uploaded) ->
            return next err if err
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              md5: 'thisisinvalid'
            , (err, uploaded) ->
              err.message.should.eql 'Invalid md5 checksum'
              next()

  it 'check sha1 for binary file', (next) ->
    @timeout 0
    mecano.execute
      cmd: "tar czf #{scratch}/source.tar.gz -C #{__dirname}/../ ."
    , (err, executed) ->
      return next err if err
      mecano.execute
        cmd: "openssl sha1 #{scratch}/source.tar.gz"
      , (err, executed, srcsum) ->
        return next err if err
        srcsum = /[ ](.*)$/.exec(srcsum.trim())[1]
        connect host: 'localhost', (err, ssh) ->
          return next err if err
          # Check valid file
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
            sha1: srcsum
          , (err, uploaded) ->
            return next err if err
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              sha1: 'thisisinvalid'
            , (err, uploaded) ->
              err.message.should.eql 'Invalid sha1 checksum'
              next()

  it 'upload binary file', (next) ->
    @timeout 0
    mecano.execute
      cmd: "tar czf #{scratch}/source.tar.gz -C #{__dirname}/../ ."
    , (err, executed) ->
      return next err if err
      mecano.execute
        cmd: "openssl sha1 #{scratch}/source.tar.gz"
      , (err, executed, srcsum) ->
        return next err if err
        connect host: 'localhost', (err, ssh) ->
          return next err if err
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
          , (err, uploaded) ->
            return next err if err
            mecano.execute
              ssh: ssh
              cmd: "openssl sha1 #{scratch}/destination.tar.gz"
            , (err, executed, dstsum) ->
              return next err if err
              srcsum = /[\w\d]+$/.exec(srcsum.trim())[0]
              dstsum = /[\w\d]+$/.exec(dstsum.trim())[0]
              srcsum.should.eql dstsum
              next()


