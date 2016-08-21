
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
    .touch
      target: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.true() unless err
    .touch
      target: "#{scratch}/a_file"
    , (err, status) ->
      status.should.be.false() unless err
    .write.assert
      target: "#{scratch}/a_file"
      content: ''
    .then next
      
  they 'as a string', (ssh, next) ->
    mecano
      ssh: ssh
    .touch "#{scratch}/a_file", (err, status) ->
      status.should.be.true() unless err
    .touch "#{scratch}/a_file", (err, status) ->
      status.should.be.false() unless err
    .write.assert
      target: "#{scratch}/a_file"
      content: ''
    .then next

  they 'an existing file', (ssh, next) ->
    mecano
      ssh: ssh
    .touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.true()
    .touch
      target: "#{scratch}/a_file"
    , (err, touched) ->
      touched.should.be.false() unless err
    .then next

  they 'change permissions', (ssh, next) ->
    mecano
      ssh: ssh
    .touch
      target: "#{scratch}/a_file"
      mode: 0o0700
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        misc.mode.compare(stat.mode, 0o0700).should.true() unless err
        callback err
    .then next
      
