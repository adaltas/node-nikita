
assert = require 'assert'
fs = require 'fs'
mecano = require '../'

module.exports =
    'link # file': (next) ->
        # Create a non existing link
        destination = "#{__dirname}/link_test"
        mecano.link
            source: __filename
            destination: destination
        , (err, linked) ->
            assert.ifError err
            assert.eql linked, 1
            # Create on an existing link
            mecano.link
                source: __filename
                destination: destination
            , (err, linked) ->
                assert.ifError err
                assert.eql linked, 0
                fs.lstat destination, (err, stat) ->
                    assert.ok stat.isSymbolicLink()
                    fs.unlink destination, next
    'link # dir': (next) ->
        # Create a non existing link
        destination = "#{__dirname}/link_test"
        mecano.link
            source: __dirname
            destination: destination
        , (err, linked) ->
            assert.ifError err
            assert.eql linked, 1
            # Create on an existing link
            mecano.link
                source: __dirname
                destination: destination
            , (err, linked) ->
                assert.ifError err
                assert.eql linked, 0
                fs.lstat destination, (err, stat) ->
                    assert.ok stat.isSymbolicLink()
                    fs.unlink destination, next
    'link # error # required arguments': (next) ->
        # Test missing source
        mecano.link
            destination: __filename
        , (err, linked) ->
            assert.eql err.message, "Missing source, got undefined"
            # Test missing destination
            mecano.link
                source: __filename
            , (err, linked) ->
                assert.eql err.message, "Missing destination, got undefined"
                next()






