
fs = require 'fs'
should = require 'should'
mecano = require '../'

describe 'link', ->

    it 'should link file', (next) ->
        # Create a non existing link
        destination = "#{__dirname}/link_test"
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
                    fs.unlink destination, next
    
    it 'should link dir', (next) ->
        # Create a non existing link
        destination = "#{__dirname}/link_test"
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
                    fs.unlink destination, next
    
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






