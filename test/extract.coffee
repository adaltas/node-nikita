
assert = require 'assert'
mecano = require '../'

module.exports =

    'extract # ext .tgz': (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
        , (err, extracted) ->
            assert.ifError err
            assert.eql extracted, 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: __dirname
            , (err, extracted) ->
                assert.ifError err
                assert.eql extracted, 1
                mecano.rm "#{__dirname}/a_dir", next
    
    'extract # ext .zip': (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.zip"
            destination: __dirname
        , (err, extracted) ->
            assert.ifError err
            assert.eql extracted, 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.zip"
                destination: __dirname
            , (err, extracted) ->
                assert.ifError err
                assert.eql extracted, 1
                mecano.rm "#{__dirname}/a_dir", next
    
    'extract # option # creates': (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
            creates: "#{__dirname}/oh_no"
        , (err, extracted) ->
            assert.eql err.message, "Failed at creating expected file, manual cleanup is required"
            # Test with valid creates option
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: __dirname
                creates: "#{__dirname}/a_dir"
            , (err, extracted) ->
                assert.ifError err
                assert.eql extracted, 1
                mecano.rm "#{__dirname}/a_dir", next
    
    'extract # option # not_if_exists': (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
            not_if_exists: __dirname
        , (err, extracted) ->
            assert.ifError err
            assert.eql extracted, 0
            next()

    'extract # error # extension': (next) ->
        mecano.extract
            source: __filename
        , (err, extracted) ->
            assert.eql err.message, 'Unsupported extension, got ".coffee"'
            next()