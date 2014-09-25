
fs = require 'ssh2-fs'
path = require 'path'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/' else require '../lib/'
test = require './test'
they = require 'ssh2-they'

describe 'remove', ->
  
  scratch = test.scratch @
  
  they 'a file', (ssh, next) ->
    mecano.copy
      ssh: ssh
      source: "#{__dirname}/../resources/a_dir/a_file"
      destination: "#{scratch}/a_file"
    , (err, copied) ->
      mecano.remove
        ssh: ssh
        source: "#{scratch}/a_file"
      , (err, removed) ->
        return next err if err
        removed.should.eql 1
        next()

  they 'a link', (ssh, next) ->
    fs.symlink ssh, __filename, "#{scratch}/test", (err) ->
      mecano.remove
        ssh: ssh
        source: "#{scratch}/test"
      , (err, removed) ->
        return next err if err
        removed.should.eql 1
        fs.lstat ssh, "#{scratch}/test", (err, stat) ->
          err.code.should.eql 'ENOENT'
          next()

  it 'use a pattern', (next) ->
    # todo, not working yet over ssh
    mecano.copy
      # ssh: ssh
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}/"
    , (err, copied) ->
      mecano.remove
        # ssh: ssh
        source: "#{scratch}/*gz"
      , (err, removed) ->
        return next err if err
        removed.should.eql 2
        fs.readdir null, "#{scratch}", (err, files) ->
          files.should.not.containEql 'a_dir.tar.gz'
          files.should.not.containEql 'a_dir.tgz'
          files.should.containEql 'a_dir.zip'
          next()

  they 'a dir', (ssh, next) ->
    @timeout 10000
    mecano.mkdir
      ssh: ssh
      destination: "#{scratch}/remove_dir"
    , (err, created) ->
      return next err if err
      mecano.remove
        ssh: ssh
        destination: "#{scratch}/remove_dir"
      , (err, removed) ->
        return next err if err
        removed.should.eql 1
        mecano.remove
          ssh: ssh
          destination: "#{scratch}/remove_dir"
        , (err, removed) ->
          return next err if err
          removed.should.eql 0
          next()

