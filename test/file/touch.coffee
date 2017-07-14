
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'file.touch', ->

  scratch = test.scratch @
  
  they 'as a target option', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .file.touch
      target: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .promise()
      
  they 'as a string', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file", (err, status) ->
      status.should.be.true() unless err
    .file.touch "#{scratch}/a_file", (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .promise()
      
  they 'as an array of strings', (ssh) ->
    nikita
      ssh: ssh
    .file.touch [
      "#{scratch}/file_1"
      "#{scratch}/file_2"
    ], (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/file_1"
      content: ''
    .file.assert
      target: "#{scratch}/file_2"
      content: ''
    .promise()

  they 'an existing file', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.true()
    .file.touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.false() unless err
    .promise()

  they 'valid default permissions', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0644).should.true() unless err
        callback err
    .promise()

  they 'change permissions', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o0700
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0700).should.true() unless err
        callback err
    .promise()

  they 'do not change permissions on existing file if not specified', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o666
    .file.touch
      target: "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0666).should.true() unless err
        callback err
    .promise()

  they 'create valid parent dir', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/subdir/a_file"
      mode:'0640'
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/subdir", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0751).should.true() unless err
        callback err
    .promise()

  they 'modify time', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        callback err
    .file.touch "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        callback err
    .promise()
