
fs = require 'fs'
path = require 'path'
should = require 'should'
mecano = require '../'

describe 'mkdir', ->

    it 'should create dir', (next) ->
        source = "#{__dirname}/a_dir"
        mecano.mkdir
            directory: source
        , (err, created) ->
            should.not.exist err
            created.should.eql 1
            mecano.mkdir
                directory: source
            , (err, created) ->
                should.not.exist err
                created.should.eql 0
                mecano.rm source, next
    
    it 'should create dir recursively', (next) ->
        source = "#{__dirname}/a_parent_dir/a_dir"
        mecano.mkdir
            directory: source
        , (err, created) ->
            should.not.exist err
            created.should.eql 1
            mecano.rm path.dirname(source), next
    
    it 'should stop when `exclude` match', (next) ->
        source = "#{__dirname}/a_parent_dir/a_dir/do_not_create_this"
        mecano.mkdir
            directory: source
            exclude: /^do/
        , (err, created) ->
            should.not.exist err
            created.should.eql 1
            path.exists source, (exists) ->
                exists.should.not.be.ok
                source = path.dirname source
                path.exists source, (exists) ->
                    exists.should.be.ok 
                    mecano.rm path.dirname(source), next

