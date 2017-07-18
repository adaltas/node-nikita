
nikita = require '../../src'
misc = require '../../src/misc'
fs = require 'ssh2-fs'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'

describe 'system.remove', ->
  
  scratch = test.scratch @
  
  they 'accept an option', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .system.remove
      source: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'accept a string', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .system.remove "#{scratch}/a_file", (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'accept an array of strings', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/file_1"
    .file.touch "#{scratch}/file_2"
    .system.remove [
      "#{scratch}/file_1"
      "#{scratch}/file_2"
    ], (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'a file', (ssh) ->
    nikita
      ssh: ssh
    .system.copy
      source: "#{__dirname}/../resources/a_dir/a_file"
      target: "#{scratch}/a_file"
    .system.remove
      source: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .system.remove
      source: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'a link', (ssh) ->
    nikita
      ssh: ssh
    .call (options, callback) ->
      fs.symlink options.ssh, __filename, "#{scratch}/test", callback
    .system.remove
      source: "#{scratch}/test"
    , (err, status) ->
      status.should.be.true() unless err
    .call (options, callback) ->
      fs.lstat options.ssh, "#{scratch}/test", (err, stat) ->
        err.code.should.eql 'ENOENT'
        callback()
    .promise()

  they 'use a pattern', (ssh) ->
    # todo, not working yet over ssh
    nikita
      ssh: ssh
    .system.copy
      source: "#{__dirname}/../resources/"
      target: "#{scratch}/"
    .system.remove
      source: "#{scratch}/*gz"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.readdir null, "#{scratch}", (err, files) ->
        files.should.not.containEql 'a_dir.tar.gz'
        files.should.not.containEql 'a_dir.tgz'
        files.should.containEql 'a_dir.zip'
        callback()
    .promise()

  they 'a dir', (ssh) ->
    # @timeout 10000
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/remove_dir"
    .system.remove
      target: "#{scratch}/remove_dir"
    , (err, status) ->
      status.should.be.true() unless err
    .system.remove
      target: "#{scratch}/remove_dir"
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
