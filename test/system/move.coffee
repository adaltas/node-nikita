
mecano = require '../../src'
test = require '../test'
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
      target: "#{scratch}"
    .system.move
      source: "#{scratch}/render.eco"
      target: "#{scratch}/moved.eco"
    , (err, status) ->
      return next err if err
      status.should.be.true()
      # The target file should exists
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
      target: "#{scratch}"
    .system.move
      source: "#{scratch}/a_dir"
      target: "#{scratch}/moved"
    , (err, status) ->
      return next err if err
      status.should.be.true()
      # The target directory should exists
      fs.exists ssh, "#{scratch}/moved", (err, exists) ->
        exists.should.be.true()
        # The source directory should no longer exists
        fs.exists ssh, "#{scratch}/a_dir", (err, exists) ->
          exists.should.be.false()
          next()

  they 'overwrite a file', (ssh, next) ->
    mecano
      ssh: ssh
    .file [
      content: "hello"
      target: "#{scratch}/src1.txt"
    ,
      content: "hello"
      target: "#{scratch}/src2.txt"
    ,
      content: "overwritten"
      target: "#{scratch}/dest.txt"
    ]
    .system.move
      source: "#{scratch}/src1.txt"
      target: "#{scratch}/dest.txt"
    , (err, status) ->
      status.should.be.true() unless err
    .system.move # Move a file with the same content
      source: "#{scratch}/src2.txt"
      target: "#{scratch}/dest.txt"
    , (err, status) ->
      return next err if err
      status.should.be.false()
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
    .file [
      content: "hello"
      target: "#{scratch}/src.txt"
    ,
      content: "hello"
      target: "#{scratch}/dest.txt"
    ]
    .system.move
      source: "#{scratch}/src.txt"
      target: "#{scratch}/dest.txt"
      force: 1
    , (err, status) ->
      status.should.be.true()
    .then next
