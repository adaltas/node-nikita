
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'

describe 'move', ->

  scratch = test.scratch @

  it 'should move a file', (next) ->
    mecano.copy
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    , (err, copied) ->
      mecano.move
        source: "#{scratch}/render.eco"
        destination: "#{scratch}/moved.eco"
      , (err, moved) ->
        should.not.exist err
        moved.should.eql 1
        fs.exists "#{scratch}/moved.eco", (exists) ->
          exists.should.be.true
          next()

  it 'should move a directory', (next) ->
    mecano.copy
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}"
    , (err, copied) ->
      mecano.move
        source: "#{scratch}/a_dir"
        destination: "#{scratch}/moved"
      , (err, moved) ->
        should.not.exist err
        moved.should.eql 1
        fs.exists "#{scratch}/moved", (exists) ->
          exists.should.be.true
          next()
