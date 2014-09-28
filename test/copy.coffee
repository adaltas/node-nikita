
path = require 'path'
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
misc = require "../#{lib}/misc"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

checkDir = (ssh, dir, callback) ->
  fs.readdir ssh, "#{__dirname}/../resources", (err, files) ->
    return callback err if err
    scratchFiles = []
    for f in files
      continue if f.substr(0, 1) is '.'
      scratchFiles.push f
    fs.readdir ssh, dir, (err, files) ->
      return callback err if err
      dirFiles = []
      for f in files
        continue if f.substr(0, 1) is '.'
        dirFiles.push f
      scratchFiles.sort().should.eql dirFiles.sort()
      callback()

describe 'copy', ->

  scratch = test.scratch @

  describe 'file', ->

    they 'with a filename inside a existing directory', (ssh, next) ->
      # @timeout 1000000
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

    they 'into an existing directory', (ssh, next) ->
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
        fs.exists ssh, "#{destination}/a_file", (err, exists) ->
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

    they 'over an existing file', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/test_this_file"
      mecano.write
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

    they 'change permissions', (ssh, next) ->
      source = "#{__dirname}/../resources/a_dir/a_file"
      destination = "#{scratch}/test_this_file"
      mecano.write
        ssh: ssh
        content: 'Hello you'
        destination: destination
      , (err, rendered) ->
        # Copy non existing file
        mecano.copy
          ssh: ssh
          source: source
          destination: destination
          mode: 0o750
        , (err, copied) ->
          return next err if err
          copied.should.eql 1
          fs.stat ssh, destination, (err, stat) ->
            misc.mode.compare(stat.mode, 0o750).should.be.ok
            # Copy existing file
            mecano.copy
              ssh: ssh
              source: source
              destination: destination
              mode: 0o755
            , (err, copied) ->
              return next err if err
              fs.stat ssh, destination, (err, stat) ->
                misc.mode.compare(stat.mode, 0o755).should.be.ok
                next()
          

  describe 'directory', ->

    they 'should copy without slash at the end', (ssh, next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources"
        destination: "#{scratch}/toto"
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        checkDir ssh, "#{scratch}/toto", (err) ->
          return next err if err
          # if the destination exists, then copy the folder inside destination
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources"
            destination: "#{scratch}/toto"
          , (err, copied) ->
            return next err if err
            copied.should.eql 1
            checkDir ssh, "#{scratch}/toto/resources", (err) ->
              next err

    they 'should copy the files when dir end with slash', (ssh, next) ->
      # if the destination doesn't exists, then copy as destination
      mecano.copy
        ssh: ssh
        source: "#{__dirname}/../resources/"
        destination: "#{scratch}/lulu"
      , (err, copied) ->
        return next err if err
        copied.should.eql 1
        checkDir ssh, "#{scratch}/lulu", (err) ->
          return next err if err
          # if the destination exists, then copy the files inside destination
          mecano.copy
            ssh: ssh
            source: "#{__dirname}/../resources/"
            destination: "#{scratch}/lulu"
          , (err, copied) ->
            return next err if err
            copied.should.eql 0
            checkDir ssh, "#{scratch}/lulu", (err) ->
              next err



