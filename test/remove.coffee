
should = require 'should'
mecano = require '../'

describe 'remove', ->

    it 'should delete a file', (next) ->
        mecano.copy
            source: "#{__dirname}/../resources/a_dir/a_file"
            destination: "#{__dirname}/a_file"
        , (err, copied) ->
            mecano.remove
                source: "#{__dirname}/a_file"
            , (err, removed) ->
                should.not.exist err
                removed.should.eql 1
                next()


