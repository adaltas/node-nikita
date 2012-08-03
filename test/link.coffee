
fs = require 'fs'
should = require 'should'
mecano = require '../'
test = require './test'

describe 'link', ->

    scratch = test.scratch @

    it 'should link file', (next) ->
        # Create a non existing link
        destination = "#{scratch}/link_test"
        await mecano.link
            source: __filename
            destination: destination
        , defer err, linked
        should.not.exist err
        linked.should.eql 1
        # Create on an existing link
        await mecano.link
            source: __filename
            destination: destination
        , defer err, linked
        should.not.exist err
        linked.should.eql 0
        await fs.lstat destination, defer err, stat
        stat.isSymbolicLink().should.be.ok
        next()
    
    it 'should link dir', (next) ->
        # Create a non existing link
        destination = "#{scratch}/link_test"
        await mecano.link
            source: __dirname
            destination: destination
        , defer err, linked
        should.not.exist err
        linked.should.eql 1
        # Create on an existing link
        await mecano.link
            source: __dirname
            destination: destination
        , defer err, linked
        should.not.exist err
        linked.should.eql 0
        await fs.lstat destination, defer err, stat
        stat.isSymbolicLink().should.be.ok
        next()
    
    it 'should create parent directories', (next) ->
        # Create a non existing link
        destination = "#{scratch}/test/dir/link_test"
        await mecano.link
            source: __dirname
            destination: destination
        , defer err, linked
        should.not.exist err
        linked.should.eql 1
        await fs.lstat destination, defer err, stat
        stat.isSymbolicLink().should.be.ok
        # Test creating two identical parent dirs
        destination = "#{scratch}/test/dir2"
        await mecano.link [
            source: "#{__dirname}/merge.coffee"
            destination: "#{destination}/merge.coffee"
        ,
            source: "#{__dirname}/mkdir.coffee"
            destination: "#{destination}/mkdir.coffee"
        ], defer err, linked
        should.not.exist err
        linked.should.eql 2
        next()
    
    it 'should validate arguments', (next) ->
        # Test missing source
        await mecano.link
            destination: __filename
        , defer err, linked
        err.message.should.eql "Missing source, got undefined"
        # Test missing destination
        await mecano.link
            source: __filename
        , defer err, linked
        err.message.should.eql "Missing destination, got undefined"
        next()






