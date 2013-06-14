
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

  they 'should move a file', (ssh, next) ->
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

  they 'should move a directory', (ssh, next) ->
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
