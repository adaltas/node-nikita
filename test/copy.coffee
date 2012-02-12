
assert = require 'assert'
fs = require 'fs'
path = require 'path'
mecano = require '../'

module.exports =

    'copy # source file # destination file': (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{__dirname}/a_new_file"
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            assert.ifError err
            assert.eql copied, 1
            mecano.copy
                source: source
                destination: destination
            , (err, copied) ->
                assert.ifError err
                assert.eql copied, 0
                mecano.rm destination, next

    'copy # source file # destination directory': (next) ->
        source = "#{__dirname}/../resources/a_dir/a_file"
        destination = "#{__dirname}/"
        # Copy non existing file
        mecano.copy
            source: source
            destination: destination
        , (err, copied) ->
            assert.ifError err
            assert.eql copied, 1
            path.exists "#{destination}/a_file", (exists) ->
                assert.ok exists
                # Copy over existing file
                mecano.copy
                    source: source
                    destination: destination
                , (err, copied) ->
                    assert.ifError err
                    assert.eql copied, 0
                    mecano.rm "#{destination}/a_file", next
    
    # 'copy # dir': (next) ->
    #     source = "#{__dirname}/../resources/a_dir"
    #     destination = "#{__dirname}/a_new_dir"
    #     mecano.copy
    #         source: source
    #         destination: destination
    #     , (err, copied) ->
    #         assert.ifError err
    #         assert.eql copied, 1
    #         mecano.copy
    #             source: source
    #             destination: destination
    #         , (err, copied) ->
    #             assert.ifError err
    #             assert.eql copied, 0
    #             mecano.rm destination, next



