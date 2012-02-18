
fs = require 'fs'
path = require 'path'
should = require 'should'
mecano = require '../'
test = require './test'

describe 'mkdir', ->

    scratch = test.scratch @

    it 'should create dir', (next) ->
        source = "#{scratch}/a_dir"
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
                next()
    
    it 'should create dir recursively', (next) ->
        source = "#{scratch}/a_parent_dir/a_dir"
        mecano.mkdir
            directory: source
        , (err, created) ->
            should.not.exist err
            created.should.eql 1
            next()
    
    it 'should stop when `exclude` match', (next) ->
        source = "#{scratch}/a_parent_dir/a_dir/do_not_create_this"
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
                    next()

    it 'should honore `cwd` for relative paths', (next) ->
        mecano.mkdir
            directory: './a_dir'
            cwd: scratch
        , (err, created) ->
            should.not.exist err
            created.should.eql 1
            path.exists "#{scratch}/a_dir", (exists) ->
                exists.should.be.ok
                next()

