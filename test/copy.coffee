
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

checkDir = (ssh, dir, callback) ->
  fs.readdir "#{__dirname}/../resources", (err, files) ->
    return callback err if err
    scratchFiles = []
    for f in files
      continue if f.substr(0, 1) is '.'
      scratchFiles.push f
    fs.readdir dir, (err, files) ->
      return callback err if err
      dirFiles = []
      for f in files
        continue if f.substr(0, 1) is '.'
        dirFiles.push f
      scratchFiles.should.eql dirFiles
      callback()

describe 'copy', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'should copy inside a directory', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/a_new_file"
      mecano.copy
        ssh: ssh
        source: source
        destination: destination
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        misc.file.compare ssh, [source, destination], (err, md5) ->
          return next err if err
          md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
          mecano.copy
            ssh: ssh
            source: source
            destination: destination
          , (err, copied) ->
            return next err if err
            copied.should.eql 0
            next()

    they 'should copy a into an existing directory', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/"
      # Copy non existing file
      mecano.copy
        ssh: ssh
        source: source
        destination: destination
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        misc.file.exists ssh, "#{destination}/a_file", (err, exists) ->
          exists.should.be.true
          # Copy over existing file
          mecano.copy
            ssh: ssh
            source: source
            destination: destination
          , (err, copied) ->
            return next err if err
            copied.should.eql 0
            next()

    they 'should copy a over an existing file', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/test_this_file"
      mecano.render
        ssh: ssh
        content: 'Hello you'
        destination: destination
      , (err, rendered) ->
        # Copy non existing file
        mecano.copy
          ssh: ssh
          source: source
          destination: destination
        , (err, copied) ->
          return next err if err
          copied.should.eql 1
          misc.file.compare ssh, [source, destination], (err, md5) ->
            return next err if err
            md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
            mecano.copy
              ssh: ssh
              source: source
              destination: destination
            , (err, copied) ->
              return next err if err
              copied.should.eql 0
              next()

  describe 'directory', ->

    they 'should copy without slash at the end', (ssh, next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources"
        destination: "#{scratch}/toto"
      , (err, copied) ->
        should.not.exists err
        copied.should.eql 8
        checkDir ssh, "#{scratch}/toto", (err) ->
          should.not.exists err
          # if the destination exists, then copy the folder inside destination
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources"
            destination: "#{scratch}/toto"
          , (err, copied) ->
            should.not.exists err
            copied.should.eql 8
            checkDir ssh, "#{scratch}/toto/resources", (err) ->
              should.not.exists err
              next()

    they 'should copy the files when dir end with slash', (ssh, next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources/"
        destination: "#{scratch}/lulu"
      , (err, copied) ->
        should.not.exists err
        copied.should.eql 8
        checkDir ssh, "#{scratch}/lulu", (err) ->
          should.not.exists err
          # if the destination exists, then copy the files inside destination
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources/"
            destination: "#{scratch}/lulu"
          , (err, copied) ->
            should.not.exists err
            copied.should.eql 0
            checkDir ssh, "#{scratch}/lulu", (err) ->
              should.not.exists err
              next()



