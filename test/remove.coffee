
assert = require 'assert'
fs = require 'fs'
mecano = require '../'

module.exports =
    'remove # file': (next) ->
        mecano.copy
            source: "#{__dirname}/../resources/a_dir/a_file"
            destination: "#{__dirname}/a_file"
        , (err, copied) ->
            mecano.remove
                source: "#{__dirname}/a_file"
            , (err, removed) ->
                assert.ifError err
                assert.eql removed, 1
                next()


