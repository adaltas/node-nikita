
assert = require 'assert'
fs = require 'fs'
mecano = require '../'

module.exports =

    'copy # file': (next) ->
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



