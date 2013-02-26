
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'

checkDir = (dir, callback) ->
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

    it 'should copy inside a directory', (next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/a_new_file"
      mecano.copy
        source: source
        destination: destination
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        misc.file.compare [source, destination], (err, md5) ->
          return next err if err
          md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
          mecano.copy
            source: source
            destination: destination
          , (err, copied) ->
            return next err if err
            copied.should.eql 0
            next()

    it 'should copy a into an existing directory', (next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/"
      # Copy non existing file
      mecano.copy
        source: source
        destination: destination
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        fs.exists "#{destination}/a_file", (exists) ->
          exists.should.be.true
          # Copy over existing file
          mecano.copy
            source: source
            destination: destination
          , (err, copied) ->
            return next err if err
            copied.should.eql 0
            next()

    it 'should copy a over an existing file', (next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/test_this_file"
      mecano.render
        content: 'Hello you'
        destination: destination
      , (err, rendered) ->
        # Copy non existing file
        mecano.copy
          source: source
          destination: destination
        , (err, copied) ->
          return next err if err
          copied.should.eql 1
          misc.file.compare [source, destination], (err, md5) ->
            return next err if err
            md5.should.eql '3fb7c40c70b0ed19da713bd69ee12014'
            mecano.copy
              source: source
              destination: destination
            , (err, copied) ->
              return next err if err
              copied.should.eql 0
              next()

  describe 'directory', ->

    it 'should copy without slash at the end', (next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        source: "#{__dirname}/../resources"
        destination: "#{scratch}/toto"
      , (err, copied) ->
        should.not.exists err
        copied.should.eql 8
        checkDir "#{scratch}/toto", (err) ->
          should.not.exists err
          # if the destination exists, then copy the folder inside destination
          mecano.copy
            source: "#{__dirname}/../resources"
            destination: "#{scratch}/toto"
          , (err, copied) ->
            should.not.exists err
            copied.should.eql 8
            checkDir "#{scratch}/toto/resources", (err) ->
              should.not.exists err
              next()

    it 'should copy the files when dir end with slash', (next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        source: "#{__dirname}/../resources/"
        destination: "#{scratch}/toto"
      , (err, copied) ->
        should.not.exists err
        copied.should.eql 8
        checkDir "#{scratch}/toto", (err) ->
          should.not.exists err
          # if the destination exists, then copy the files inside destination
          mecano.copy
            source: "#{__dirname}/../resources/"
            destination: "#{scratch}/toto"
          , (err, copied) ->
            should.not.exists err
            copied.should.eql 0
            checkDir "#{scratch}/toto", (err) ->
              should.not.exists err
              next()



