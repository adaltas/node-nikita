
fs = require 'fs'
path = require 'path'
exists = fs.exists or path.exists
should = require 'should'
mecano = require '../'
test = require './test'

describe 'copy', ->

    scratch = test.scratch @

    it 'should only copy if destination does not exists', (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{scratch}/a_new_file"
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
                next()

    it 'should always copy with `force` option', (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{scratch}/a_new_file"
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            should.not.exist err
            copied.should.eql 1
            mecano.copy
                source: source
                destination: destination
                force: true
            , (err, copied) ->
                should.not.exist err
                copied.should.eql 1
                next()

    it 'should copy a file into an existing directory', (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{scratch}/"
        # Copy non existing file
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            should.not.exist err
            copied.should.eql 1
            exists "#{destination}/a_file", (exists) ->
                should.ok exists
                # Copy over existing file
                mecano.copy
                    source: source
                    destination: destination
                , (err, copied) ->
                    should.not.exist err
                    copied.should.eql 0
                    next()
    
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
    #             next()



