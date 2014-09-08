
fs = require 'fs'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/' else require '../lib/'
misc = if process.env.MECANO_COV then require '../lib-cov/misc' else require '../lib/misc'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'link', ->

  scratch = test.scratch @

  they 'should link file', (ssh, next) ->
    # Create a non existing link
    destination = "#{scratch}/link_test"
    mecano.link
      ssh: ssh
      source: __filename
      destination: destination
    , (err, linked) ->
      return next err if err
      linked.should.eql 1
      # Create on an existing link
      mecano.link
        ssh: ssh
        source: __filename
        destination: destination
      , (err, linked) ->
        return next err if err
        linked.should.eql 0
        fs.lstat ssh, destination, (err, stat) ->
          stat.isSymbolicLink().should.be.ok
          next()
  
  they 'should link dir', (ssh, next) ->
    # Create a non existing link
    destination = "#{scratch}/link_test"
    mecano.link
      ssh: ssh
      source: __dirname
      destination: destination
    , (err, linked) ->
      return next err if err
      linked.should.eql 1
      # Create on an existing link
      mecano.link
        ssh: ssh
        source: __dirname
        destination: destination
      , (err, linked) ->
        return next err if err
        linked.should.eql 0
        fs.lstat ssh, destination, (err, stat) ->
          stat.isSymbolicLink().should.be.ok
          next()
  
  they 'should create parent directories', (ssh, next) ->
    # Create a non existing link
    destination = "#{scratch}/test/dir/link_test"
    mecano.link
      ssh: ssh
      source: __dirname
      destination: destination
    , (err, linked) ->
      return next err if err
      linked.should.eql 1
      fs.lstat ssh, destination, (err, stat) ->
        stat.isSymbolicLink().should.be.ok
        # Test creating two identical parent dirs
        destination = "#{scratch}/test/dir2"
        mecano.link [
          ssh: ssh
          source: "#{__dirname}/merge.coffee"
          destination: "#{destination}/merge.coffee"
        ,
          ssh: ssh
          source: "#{__dirname}/mkdir.coffee"
          destination: "#{destination}/mkdir.coffee"
        ], (err, linked) ->
          return next err if err
          linked.should.eql 2
          next()
  
  they 'should validate arguments', (ssh, next) ->
    # Test missing source
    mecano.link
      ssh: ssh
      destination: __filename
    , (err, linked) ->
      err.message.should.eql "Missing source, got undefined"
      # Test missing destination
      mecano.link
        ssh: ssh
        source: __filename
      , (err, linked) ->
        err.message.should.eql "Missing destination, got undefined"
        next()






