
mecano = require '../../src'
misc = require '../../src/misc'
fs = require 'ssh2-fs'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'

describe 'remove', ->
  
  scratch = test.scratch @
  
  they 'accept an option', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .remove
      source: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .then next
    
  they 'accept a string', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .remove "#{scratch}/a_file", (err, status) ->
      status.should.be.true() unless err
    .then next
    
  they 'accept an array of strings', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch "#{scratch}/file_1"
    .file.touch "#{scratch}/file_2"
    .remove [
      "#{scratch}/file_1"
      "#{scratch}/file_2"
    ], (err, status) ->
      status.should.be.true() unless err
    .then next
    
  they 'accept an empty array', (ssh, next) ->
    mecano
      ssh: ssh
    .remove [], (err, status) ->
      status.should.be.false() unless err
    .then next
    
  they 'a file', (ssh, next) ->
    mecano
      ssh: ssh
    .copy
      source: "#{__dirname}/../resources/a_dir/a_file"
      target: "#{scratch}/a_file"
    .remove
      source: "#{scratch}/a_file"
    , (err, status) ->
      return next err if err
      status.should.be.true()
    .then next

  they 'a link', (ssh, next) ->
    fs.symlink ssh, __filename, "#{scratch}/test", (err) ->
      mecano.remove
        ssh: ssh
        source: "#{scratch}/test"
      , (err, status) ->
        return next err if err
        status.should.be.true()
        fs.lstat ssh, "#{scratch}/test", (err, stat) ->
          err.code.should.eql 'ENOENT'
          next()

  they 'use a pattern', (ssh, next) ->
    # todo, not working yet over ssh
    mecano
      ssh: ssh
    .copy
      source: "#{__dirname}/../resources/"
      target: "#{scratch}/"
    .remove
      source: "#{scratch}/*gz"
    , (err, status) ->
      return next err if err
      status.should.be.true()
      fs.readdir null, "#{scratch}", (err, files) ->
        files.should.not.containEql 'a_dir.tar.gz'
        files.should.not.containEql 'a_dir.tgz'
        files.should.containEql 'a_dir.zip'
        next()

  they 'a dir', (ssh, next) ->
    @timeout 10000
    mecano
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/remove_dir"
    .remove
      target: "#{scratch}/remove_dir"
    , (err, status) ->
      status.should.be.true()
    .remove
      target: "#{scratch}/remove_dir"
    , (err, status) ->
      status.should.be.false()
    .then next
