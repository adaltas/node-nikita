
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
connect = require 'superexec/lib/connect'

describe 'mkdir', ->

  scratch = test.scratch @

  it 'should create dir', (next) ->
    source = "#{scratch}/a_dir"
    mecano.mkdir
      directory: source
    , (err, created) ->
      return next err if err
      created.should.eql 1
      mecano.mkdir
        directory: source
      , (err, created) ->
        return next err if err
        created.should.eql 0
        next()

  it 'should take source if first argument is a string', (next) ->
    source = "#{scratch}/a_dir"
    mecano.mkdir source, (err, created) ->
      return next err if err
      created.should.eql 1
      mecano.mkdir source, (err, created) ->
        return next err if err
        created.should.eql 0
        next()
  
  it 'should create dir recursively', (next) ->
    source = "#{scratch}/a_parent_dir/a_dir"
    mecano.mkdir
      directory: source
    , (err, created) ->
      return next err if err
      created.should.eql 1
      next()
  
  it 'should stop when `exclude` match', (next) ->
    source = "#{scratch}/a_parent_dir/a_dir/do_not_create_this"
    mecano.mkdir
      directory: source
      exclude: /^do/
    , (err, created) ->
      return next err if err
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
      return next err if err
      created.should.eql 1
      fs.exists "#{scratch}/a_dir", (created) ->
        created.should.be.ok
        next()

  it 'should work over ssh', (next) ->
    @timeout 10000
    connect host: 'localhost', (err, ssh) ->
      mecano.mkdir
        ssh: ssh
        directory: "#{scratch}/ssh_dir_string"
        chmod: '744'
      , (err, created) ->
        return next err if err
        connect host: 'localhost', (err, ssh) ->
          mecano.mkdir
            ssh: ssh
            directory: "#{scratch}/ssh_dir_octal"
            chmod: 0o744
          , (err, created) ->
            return next err if err
            ssh.sftp (err, sftp) ->
              sftp.stat "#{scratch}/ssh_dir_string", (err, attr_string) ->
                return next err if err
                sftp.stat "#{scratch}/ssh_dir_octal", (err, attr_octal) ->
                  return next err if err
                  attr_string.permissions.should.eql attr_octal.permissions
                  next()

