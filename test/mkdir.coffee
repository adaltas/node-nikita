
assert = require 'assert'
fs = require 'fs'
path = require 'path'
mecano = require '../'

module.exports = 
    'mkdir # source # parent exists': (next) ->
        source = "#{__dirname}/a_dir"
        mecano.mkdir
            directory: source
        , (err, created) ->
            assert.ifError err
            assert.eql created, 1
            mecano.mkdir
                directory: source
            , (err, created) ->
                assert.ifError err
                assert.eql created, 0
                mecano.rm source, next
    'mkdir # source # parent missing': (next) ->
        source = "#{__dirname}/a_parent_dir/a_dir"
        mecano.mkdir
            directory: source
        , (err, created) ->
            assert.ifError err
            assert.eql created, 1
            mecano.rm path.dirname(source), next
    'mkdir # exlude': (next) ->
        source = "#{__dirname}/a_parent_dir/a_dir/do_not_create_this"
        mecano.mkdir
            directory: source
            exclude: /^do/
        , (err, created) ->
            assert.ifError err
            assert.eql created, 1
            path.exists source, (exists) ->
                assert.ok not exists
                source = path.dirname source
                path.exists source, (exists) ->
                    assert.ok exists
                    mecano.rm path.dirname(source), next

