
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
misc = require '../lib/misc'
test = require './test'
they = require 'superexec/lib/they'

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
        misc.file.exists ssh, "#{scratch}/moved.eco", (err, exists) ->
          exists.should.be.true
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
        misc.file.exists ssh, "#{scratch}/moved", (err, exists) ->
          exists.should.be.true
          next()

  they 'overwrite a file', (ssh, next) ->
    mecano.write [
      ssh: ssh
      content: "hello"
      destination: "#{scratch}/src.txt"
    ,
      ssh: ssh
      content: "overwrite"
      destination: "#{scratch}/dest.txt"
    ], (err, copied) ->
      return next err if err
      # Throw exception wihtout force
      mecano.move
        ssh: ssh
        source: "#{scratch}/src.txt"
        destination: "#{scratch}/dest.txt"
      , (err, moved) ->
        err.message.should.eql 'Destination already exists, use the force option'
        mecano.move
          ssh: ssh
          source: "#{scratch}/src.txt"
          destination: "#{scratch}/dest.txt"
          force: true
        , (err, moved) ->
          return next err if err
          moved.should.eql 1
          misc.file.readFile ssh, "#{scratch}/dest.txt", 'utf8', (err, content) ->
            return next err if err
            content.should.eql 'hello'
            next()



