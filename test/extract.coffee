
should = require 'should'
mecano = require '../'
test = require './test'

describe 'extract', ->

    scratch = test.scratch @

    it 'should see extension .tgz', (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: scratch
        , (err, extracted) ->
            should.not.exist err
            extracted.should.eql 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: scratch
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                next()
    
    it 'should see extension .zip', (next) ->
        # Test a non existing extracted dir
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.zip"
            destination: scratch
        , (err, extracted) ->
            should.not.exist err
            extracted.should.eql 1
            # Test an existing extracted dir
            # Note, there is no way for us to know which directory
            # it is in advance
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.zip"
                destination: scratch
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                next()
    
    it 'should validate a created file', (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: scratch
            creates: "#{scratch}/oh_no"
        , (err, extracted) ->
            err.message.should.eql "Failed to create 'oh_no'"
            # Test with valid creates option
            mecano.extract
                source: "#{__dirname}/../resources/a_dir.tgz"
                destination: scratch
                creates: "#{scratch}/a_dir"
            , (err, extracted) ->
                should.not.exist err
                extracted.should.eql 1
                next()
    
    it 'should # option # not_if_exists', (next) ->
        # Test with invalid creates option
        mecano.extract
            source: "#{__dirname}/../resources/a_dir.tgz"
            destination: scratch
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


