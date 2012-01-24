
assert = require 'assert'
mecano = require '../'

module.exports =

    'simple # ext .tgz': (next) ->
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
    
    'simple # ext .zip': (next) ->
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
    
    'option # creates': (next) ->
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
    
    'option # not_if': (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
            not_if: __dirname
        , (err, extracted) ->
            assert.ifError err
            assert.eql extracted, 0
            next()

    'error # extension': (next) ->
        mecano.extract
            source: __filename
        , (err, extracted) ->
            assert.eql err.message, 'Unsupported extension, got ".coffee"'
            next()