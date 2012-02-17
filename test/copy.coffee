
fs = require 'fs'
path = require 'path'
should = require 'should'
mecano = require '../'

describe 'copy', ->

    it 'should only copy if destination does not exists', (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{__dirname}/a_new_file"
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            should.not.exist err
            copied.should.eql 1
            mecano.copy
                source: source
                destination: destination
            , (err, copied) ->
                should.not.exist err
                copied.should.eql 0
                mecano.rm destination, next

    it 'should copy a file into an existing directory', (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{__dirname}/"
        # Copy non existing file
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            should.not.exist err
            copied.should.eql 1
            path.exists "#{destination}/a_file", (exists) ->
                should.ok exists
                # Copy over existing file
                mecano.copy
                    source: source
                    destination: destination
                , (err, copied) ->
                    should.not.exist err
                    copied.should.eql 0
                    mecano.rm "#{destination}/a_file", next
    
    # it 'should copy a directory', (next) ->
    #     source = "#{__dirname}/../resources/a_dir"
    #     destination = "#{__dirname}/a_new_dir"
    #     mecano.copy
    #         source: source
    #         destination: destination
    #     , (err, copied) ->
    #         should.not.exist err
    #         copied.should.eql 1
    #         mecano.copy
    #             source: source
    #             destination: destination
    #         , (err, copied) ->
    #             should.not.exist err
    #             copied.should.eql 0
    #             mecano.rm destination, next



