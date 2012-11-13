
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
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
      fs.exists source, (created) ->
        created.should.not.be.ok
        source = path.dirname source
        fs.exists source, (created) ->
          created.should.be.ok 
          next()

  it 'should honore `cwd` for relative paths', (next) ->
    mecano.mkdir
      directory: './a_dir'
      cwd: scratch
    , (err, created) ->
      should.not.exist err
      created.should.eql 1
      fs.exists "#{scratch}/a_dir", (created) ->
        created.should.be.ok
        next()

