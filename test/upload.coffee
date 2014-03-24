
fs = require 'fs'
path = require 'path'
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
            uploaded.should.eql 1
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              sha1: srcsum
            , (err, uploaded) ->
              return next err if err
              uploaded.should.eql 0
              next()

  it 'check invalid file digest', (next) ->
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
          # Destination does not yet exist
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
            md5: 'thisisinvalid'
          , (err, uploaded) ->
            err.message.should.eql 'Invalid md5 checksum'
            next()

  it 'check digest over an invalid existing file', (next) ->
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
          # Upload invalid file
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{__filename}"
            destination: "#{scratch}/destination.tar.gz"
          , (err, uploaded) ->
            return next err if err
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              md5: srcsum
            , (err, uploaded) ->
              return next err if err
              uploaded.should.eql 1
              next()

  it 'into a directory', (next) ->
    connect host: 'localhost', (err, ssh) ->
      return next err if err
      mecano.upload
        ssh: ssh
        source: "#{__filename}"
        destination: "#{scratch}"
      , (err, uploaded) ->
        return next err if err
        uploaded.should.eql 1
        misc.file.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exist) ->
          return next err if err
          exist.should.be.ok
          mecano.upload
            ssh: ssh
            source: "#{__filename}"
            destination: "#{scratch}"
          , (err, uploaded) ->
            return next err if err
            uploaded.should.eql 0
            next()

  describe 'binary', ->

    it 'with a file', (next) ->
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

    it 'into a directory', (next) ->
      connect host: 'localhost', (err, ssh) ->
        return next err if err
        mecano.upload
          ssh: ssh
          binary: true
          source: "#{__filename}"
          destination: "#{scratch}"
        , (err, uploaded) ->
          return next err if err
          uploaded.should.eql 1
          misc.file.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exist) ->
            return next err if err
            exist.should.be.ok
            next()
            # TODO: for now, uploading binary doesnt check if the file has been changed
            # mecano.upload
            #   ssh: ssh
            #   binary: true
            #   source: "#{__filename}"
            #   destination: "#{scratch}"
            # , (err, uploaded) ->
            #   return next err if err
            #   uploaded.should.eql 0
            #   next()







