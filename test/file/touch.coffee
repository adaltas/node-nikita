
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'touch', ->

  scratch = test.scratch @
  
  they 'as a target option', (ssh, next) ->
    mecano
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
    .then next
      
  they 'as a string', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch "#{scratch}/a_file", (err, status) ->
      status.should.be.true() unless err
    .file.touch "#{scratch}/a_file", (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .then next
      
  they 'as an array of strings', (ssh, next) ->
    mecano
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
    .then next

  they 'an existing file', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.true()
    .file.touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.false() unless err
    .then next

  they 'valid default permissions', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0644).should.true() unless err
        callback err
    .then next

  they 'change permissions', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o0700
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0700).should.true() unless err
        callback err
    .then next

  they 'do not change permissions on existing file if not specified', (ssh, next) ->
    mecano
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
    .then next

  they 'create valid parent dir', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch
      target: "#{scratch}/subdir/a_file"
      mode:'0640'
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/subdir", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0751).should.true() unless err
        callback err
    .then next

  they 'modify time', (ssh, next) ->
    mecano
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        callback err
    .file.touch "#{scratch}/a_file"
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        callback err
    .then next
