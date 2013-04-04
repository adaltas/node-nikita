
fs = require 'fs'
path = require 'path'
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
connect = require 'superexec/lib/connect'

describe 'remove', ->
  
  scratch = test.scratch @
  
  it 'should delete a file', (next) ->
    mecano.copy
      source: "#{__dirname}/../resources/a_dir/a_file"
      destination: "#{scratch}/a_file"
    , (err, copied) ->
      mecano.remove
        source: "#{scratch}/a_file"
      , (err, removed) ->
        return next err if err
        removed.should.eql 1
        next()

  it 'should delete a link', (next) ->
    fs.symlink __filename, "#{scratch}/test", (err) ->
      mecano.remove
        source: "#{scratch}/test"
      , (err, removed) ->
        return next err if err
        removed.should.eql 1
        fs.lstat "#{scratch}/test", (err, stat) ->
          err.code.should.eql 'ENOENT'
          next()

  it 'should delete a pattern', (next) ->
    mecano.copy
      source: "#{__dirname}/../resources/"
      destination: "#{scratch}/"
    , (err, copied) ->
      mecano.remove
        source: "#{scratch}/*gz"
      , (err, removed) ->
        return next err if err
        removed.should.eql 2
        fs.readdir "#{scratch}", (err, files) ->
          files.should.not.include 'a_dir.tar.gz'
          files.should.not.include 'a_dir.tgz'
          files.should.include 'a_dir.zip'
          next()

  it 'work over ssh', (next) ->
    @timeout 10000
    connect host: 'localhost', (err, ssh) ->
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
          connect host: 'localhost', (err, ssh) ->
            mecano.remove
              ssh: ssh
              destination: "#{scratch}/remove_dir"
            , (err, removed) ->
              return next err if err
              removed.should.eql 0
              next()

