
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'move', ->

  scratch = test.scratch @

  they 'rename a file', (ssh, next) ->
    mecano.copy
      # ssh: ssh # copy not there yet
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    , (err, copied) ->
      mecano.move
        ssh: ssh
        source: "#{scratch}/render.eco"
        destination: "#{scratch}/moved.eco"
      , (err, moved) ->
        return next err if err
        moved.should.eql 1
        # The destination file should exists
        fs.exists ssh, "#{scratch}/moved.eco", (err, exists) ->
          exists.should.be.true
          # The source file should no longer exists
          fs.exists ssh, "#{scratch}/render.eco", (err, exists) ->
            exists.should.be.false
            next()

  they 'rename a directory', (ssh, next) ->
    mecano.copy
      # ssh: ssh # copy not there yet
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    , (err, copied) ->
      mecano.move
        ssh: ssh
        source: "#{scratch}/a_dir"
        destination: "#{scratch}/moved"
      , (err, moved) ->
        return next err if err
        moved.should.eql 1
        # The destination directory should exists
        fs.exists ssh, "#{scratch}/moved", (err, exists) ->
          exists.should.be.true
          # The source directory should no longer exists
          fs.exists ssh, "#{scratch}/a_dir", (err, exists) ->
            exists.should.be.false
            next()

  they 'overwrite a file', (ssh, next) ->
    mecano.write [
      ssh: ssh
      content: "hello"
      destination: "#{scratch}/src1.txt"
    ,
      ssh: ssh
      content: "hello"
      destination: "#{scratch}/src2.txt"
    ,
      ssh: ssh
      content: "overwritten"
      destination: "#{scratch}/dest.txt"
    ], (err, copied) ->
      return next err if err
      mecano.move
        ssh: ssh
        source: "#{scratch}/src1.txt"
        destination: "#{scratch}/dest.txt"
      , (err, moved) ->
        return next err if err
        moved.should.eql 1
        # Move a file with the same content
        mecano.move
          ssh: ssh
          source: "#{scratch}/src2.txt"
          destination: "#{scratch}/dest.txt"
        , (err, moved) ->
          return next err if err
          moved.should.eql 0
          fs.readFile ssh, "#{scratch}/dest.txt", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'hello'
            # The original file should no longer exists
            fs.exists ssh, "#{scratch}/src2.txt", (err, exists) ->
              exists.should.be.false
              next()

  they 'force bypass checksum comparison', (ssh, next) ->
    mecano.write [
      ssh: ssh
      content: "hello"
      destination: "#{scratch}/src.txt"
    ,
      ssh: ssh
      content: "hello"
      destination: "#{scratch}/dest.txt"
    ], (err, copied) ->
      return next err if err
      mecano.move
        ssh: ssh
        source: "#{scratch}/src.txt"
        destination: "#{scratch}/dest.txt"
        force: 1
      , (err, moved) ->
        return next err if err
        moved.should.eql 1
        next()



