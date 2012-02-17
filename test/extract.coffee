
should = require 'should'
mecano = require '../'

describe 'extract', ->

    it 'should see extension .tgz', (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
        , (err, extracted) ->
            should.not.exist err
            extracted.should.eql 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: __dirname
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                mecano.rm "#{__dirname}/a_dir", next
    
    it 'should see extension .zip', (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.zip"
            destination: __dirname
        , (err, extracted) ->
            should.not.exist err
            extracted.should.eql 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.zip"
                destination: __dirname
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                mecano.rm "#{__dirname}/a_dir", next
    
    it 'should validate a created file', (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
            creates: "#{__dirname}/oh_no"
        , (err, extracted) ->
            err.message.should.eql "Failed to create 'oh_no'"
            # Test with valid creates option
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: __dirname
                creates: "#{__dirname}/a_dir"
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                mecano.rm "#{__dirname}/a_dir", next
    
    it 'should # option # not_if_exists', (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: __dirname
            not_if_exists: __dirname
        , (err, extracted) ->
            should.not.exist err
            extracted.should.eql 0
            next()

    it 'should # error # extension', (next) ->
        mecano.extract
            source: __filename
        , (err, extracted) ->
            err.message.should.eql 'Unsupported extension, got ".coffee"'
            next()


