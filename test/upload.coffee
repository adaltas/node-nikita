
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
they = require 'superexec/lib/they'
misc = require '../lib/misc'
connect = require 'superexec/lib/connect'

describe 'upload', ->

  scratch = test.scratch @

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


