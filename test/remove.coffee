
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
misc = require "../#{lib}/misc"
fs = require 'ssh2-fs'
path = require 'path'
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
        removed.should.be.ok
        next()

  they 'a link', (ssh, next) ->
    fs.symlink ssh, __filename, "#{scratch}/test", (err) ->
      mecano.remove
        ssh: ssh
        source: "#{scratch}/test"
      , (err, removed) ->
        return next err if err
        removed.should.be.ok
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
        removed.should.be.ok
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
        removed.should.be.ok
        mecano.remove
          ssh: ssh
          destination: "#{scratch}/remove_dir"
        , (err, removed) ->
          return next err if err
          removed.should.not.be.ok
          next()

