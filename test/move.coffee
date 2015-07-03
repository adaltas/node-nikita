
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'move', ->

  scratch = test.scratch @

  they 'rename a file', (ssh, next) ->
    mecano
      ssh: ssh
    .copy
      # ssh: ssh # copy not there yet
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    .move
      source: "#{scratch}/render.eco"
      destination: "#{scratch}/moved.eco"
    , (err, moved) ->
      return next err if err
      moved.should.be.true()
      # The destination file should exists
      fs.exists ssh, "#{scratch}/moved.eco", (err, exists) ->
        exists.should.be.true()
        # The source file should no longer exists
        fs.exists ssh, "#{scratch}/render.eco", (err, exists) ->
          exists.should.be.false()
          next()

  they 'rename a directory', (ssh, next) ->
    mecano
      ssh: ssh
    .copy
      # ssh: ssh # copy not there yet
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    .move
      source: "#{scratch}/a_dir"
      destination: "#{scratch}/moved"
    , (err, moved) ->
      return next err if err
      moved.should.be.true()
      # The destination directory should exists
      fs.exists ssh, "#{scratch}/moved", (err, exists) ->
        exists.should.be.true()
        # The source directory should no longer exists
        fs.exists ssh, "#{scratch}/a_dir", (err, exists) ->
          exists.should.be.false()
          next()

  they 'overwrite a file', (ssh, next) ->
    mecano
      ssh: ssh
    .write [
      content: "hello"
      destination: "#{scratch}/src1.txt"
    ,
      content: "hello"
      destination: "#{scratch}/src2.txt"
    ,
      content: "overwritten"
      destination: "#{scratch}/dest.txt"
    ]
    .move
      source: "#{scratch}/src1.txt"
      destination: "#{scratch}/dest.txt"
    , (err, moved) ->
      moved.should.be.true()
    .move # Move a file with the same content
      source: "#{scratch}/src2.txt"
      destination: "#{scratch}/dest.txt"
    , (err, moved) ->
      return next err if err
      moved.should.be.false()
      fs.readFile ssh, "#{scratch}/dest.txt", 'utf8', (err, content) ->
        return next err if err
        content.should.eql 'hello'
        # The original file should no longer exists
        fs.exists ssh, "#{scratch}/src2.txt", (err, exists) ->
          exists.should.be.false()
          next()

  they 'force bypass checksum comparison', (ssh, next) ->
    mecano
      ssh: ssh
    .write [
      content: "hello"
      destination: "#{scratch}/src.txt"
    ,
      content: "hello"
      destination: "#{scratch}/dest.txt"
    ]
    .move
      source: "#{scratch}/src.txt"
      destination: "#{scratch}/dest.txt"
      force: 1
    , (err, moved) ->
      moved.should.be.true()
    .then next



