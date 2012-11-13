
fs = require 'fs'
should = require 'should'
mecano = require '../'
test = require './test'

describe 'link', ->

  scratch = test.scratch @

  it 'should link file', (next) ->
    # Create a non existing link
    destination = "#{scratch}/link_test"
    mecano.link
      source: __filename
      destination: destination
    , (err, linked) ->
      should.not.exist err
      linked.should.eql 1
      # Create on an existing link
      mecano.link
        source: __filename
        destination: destination
      , (err, linked) ->
        should.not.exist err
        linked.should.eql 0
        fs.lstat destination, (err, stat) ->
          stat.isSymbolicLink().should.be.ok
          next()
  
  it 'should link dir', (next) ->
    # Create a non existing link
    destination = "#{scratch}/link_test"
    mecano.link
      source: __dirname
      destination: destination
    , (err, linked) ->
      should.not.exist err
      linked.should.eql 1
      # Create on an existing link
      mecano.link
        source: __dirname
        destination: destination
      , (err, linked) ->
        should.not.exist err
        linked.should.eql 0
        fs.lstat destination, (err, stat) ->
          stat.isSymbolicLink().should.be.ok
          next()
  
  it 'should create parent directories', (next) ->
    # Create a non existing link
    destination = "#{scratch}/test/dir/link_test"
    mecano.link
      source: __dirname
      destination: destination
    , (err, linked) ->
      should.not.exist err
      linked.should.eql 1
      fs.lstat destination, (err, stat) ->
        stat.isSymbolicLink().should.be.ok
        # Test creating two identical parent dirs
        destination = "#{scratch}/test/dir2"
        mecano.link [
          source: "#{__dirname}/merge.coffee"
          destination: "#{destination}/merge.coffee"
        ,
          source: "#{__dirname}/mkdir.coffee"
          destination: "#{destination}/mkdir.coffee"
        ], (err, linked) ->
          should.not.exist err
          linked.should.eql 2
          next()
  
  it 'should validate arguments', (next) ->
    # Test missing source
    mecano.link
      destination: __filename
    , (err, linked) ->
      err.message.should.eql "Missing source, got undefined"
      # Test missing destination
      mecano.link
        source: __filename
      , (err, linked) ->
        err.message.should.eql "Missing destination, got undefined"
        next()






