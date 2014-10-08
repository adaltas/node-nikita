
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
misc = require "../#{lib}/misc"
path = require 'path'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'upload', ->

  scratch = test.scratch @

  they 'into a directory', (ssh, next) ->
      return next() unless ssh
      mecano.upload
        ssh: ssh
        source: "#{__filename}"
        destination: "#{scratch}"
      , (err, uploaded) ->
        return next err if err
        uploaded.should.be.ok
        fs.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exist) ->
          return next err if err
          exist.should.be.ok
          mecano.upload
            ssh: ssh
            source: "#{__filename}"
            destination: "#{scratch}"
          , (err, uploaded) ->
            return next err if err
            uploaded.should.not.be.ok
            next()

  describe 'binary', ->

    they 'with md5 true', (ssh, next) ->
      return next() unless ssh
      @timeout 0
      # Force md5 validation
      mecano.execute
        cmd: "tar czf #{scratch}/source.tar.gz -C #{__dirname}/../ ."
      , (err, executed) ->
        return next err if err
        misc.file.hash null, "#{scratch}/source.tar.gz", 'md5', (err, srcsum) ->
          return next err if err
          dstsum = null
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
            log: (msg) ->
              dstsum = match[1] if match = /checksum is "(.*)"$/.exec msg
            md5: true
          , (err, uploaded) ->
            return next err if err
            dstsum.should.eql srcsum
            uploaded.should.be.ok
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              md5: true
            , (err, uploaded) ->
              return next err if err
              uploaded.should.not.be.ok
              next()

    they 'with md5 string', (ssh, next) ->
      return next() unless ssh
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

    they 'with sha1 string', (ssh, next) ->
      return next() unless ssh
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
          # Check valid file
          mecano.upload
            ssh: ssh
            binary: true
            source: "#{scratch}/source.tar.gz"
            destination: "#{scratch}/destination.tar.gz"
            sha1: srcsum
          , (err, uploaded) ->
            return next err if err
            uploaded.should.be.ok
            mecano.upload
              ssh: ssh
              binary: true
              source: "#{scratch}/source.tar.gz"
              destination: "#{scratch}/destination.tar.gz"
              sha1: srcsum
            , (err, uploaded) ->
              return next err if err
              uploaded.should.not.be.ok
              next()

    they 'with invalid md5 string', (ssh, next) ->
      return next() unless ssh
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

    they 'with md5 string on invalid file', (ssh, next) ->
      return next() unless ssh
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
              uploaded.should.be.ok
              next()

    they 'with a file', (ssh, next) ->
      return next() unless ssh
      @timeout 0
      mecano.execute
        cmd: "tar czf #{scratch}/source.tar.gz -C #{__dirname}/../ ."
      , (err, executed) ->
        return next err if err
        mecano.execute
          cmd: "openssl sha1 #{scratch}/source.tar.gz"
        , (err, executed, srcsum) ->
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

    they 'into a directory', (ssh, next) ->
      return next() unless ssh
      mecano.upload
        ssh: ssh
        binary: true
        source: "#{__filename}"
        destination: "#{scratch}"
      , (err, uploaded) ->
        return next err if err
        uploaded.should.be.ok
        fs.exists ssh, "#{scratch}/#{path.basename __filename}", (err, exist) ->
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
          #   uploaded.should.not.be.ok
          #   next()







