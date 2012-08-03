
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = require '../'
test = require './test'

describe 'mkdir', ->

    scratch = test.scratch @

    it 'should create dir', (next) ->
        source = "#{scratch}/a_dir"
        await mecano.mkdir
            directory: source
        , defer err, created
        should.not.exist err
        created.should.eql 1
        await mecano.mkdir
            directory: source
        , defer err, created
        should.not.exist err
        created.should.eql 0
        next()
    
    it 'should create dir recursively', (next) ->
        source = "#{scratch}/a_parent_dir/a_dir"
        await mecano.mkdir
            directory: source
        , defer err, created
        should.not.exist err
        created.should.eql 1
        next()
    
    it 'should stop when `exclude` match', (next) ->
        source = "#{scratch}/a_parent_dir/a_dir/do_not_create_this"
        await mecano.mkdir
            directory: source
            exclude: /^do/
        , defer err, created
        should.not.exist err
        created.should.eql 1
        await fs.exists source, defer created
        created.should.not.be.ok
        source = path.dirname source
        await fs.exists source, defer created
        created.should.be.ok 
        next()

    it 'should honore `cwd` for relative paths', (next) ->
        await mecano.mkdir
            directory: './a_dir'
            cwd: scratch
        , defer err, created
        should.not.exist err
        created.should.eql 1
        await fs.exists "#{scratch}/a_dir", defer created
        created.should.be.ok
        next()

