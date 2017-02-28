
fs = require 'fs'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'system.link', ->

  scratch = test.scratch @

  they 'should link file', (ssh, next) ->
    # Create a non existing link
    target = "#{scratch}/link_test"
    mecano
      ssh: ssh
    .system.link # Link does not exist
      source: __filename
      target: target
    , (err, status) ->
      status.should.be.true() unless err
    .system.link # Link already exists
      source: __filename
      target: target
    , (err, status) ->
      status.should.be.false() unless err
    .then (err) ->
      return next err if err
      fs.lstat ssh, target, (err, stat) ->
        stat.isSymbolicLink().should.be.true()
        next()
  
  they 'should link dir', (ssh, next) ->
    # Create a non existing link
    target = "#{scratch}/link_test"
    mecano
      ssh: ssh
    .system.link # Link does not exist
      source: __dirname
      target: target
    , (err, status) ->
      status.should.be.true() unless err
    .system.link # Link already exists
      ssh: ssh
      source: __dirname
      target: target
    , (err, status) ->
      status.should.be.false() unless err
    .then (err) ->
      return next err if err
      fs.lstat ssh, target, (err, stat) ->
        stat.isSymbolicLink().should.be.true()
        next()
  
  they 'should create parent directories', (ssh, next) ->
    # Create a non existing link
    mecano
      ssh: ssh
    .system.link
      source: __dirname
      target: "#{scratch}/test/dir/link_test"
    , (err, status) ->
      status.should.be.true() unless err
    .call (_, callback) ->
      fs.lstat ssh, "#{scratch}/test/dir/link_test", (err, stat) ->
        stat.isSymbolicLink().should.be.true() unless err
        callback err
    .system.link [
      ssh: ssh
      source: "#{__dirname}/merge.coffee"
      target: "#{scratch}/test/dir2/merge.coffee"
    ,
      ssh: ssh
      source: "#{__dirname}/mkdir.coffee"
      target: "#{scratch}/test/dir2/mkdir.coffee"
    ], (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should override invalid link', (ssh, next) ->
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/test/invalid_file"
      content: 'error'
    .file
      target: "#{scratch}/test/valid_file"
      content: 'ok'
    .system.link
      source: "#{scratch}/test/invalid_file"
      target: "#{scratch}/test/file_link"
    , (err, status) ->
      status.should.be.true() unless err
    .system.remove
      target: "#{scratch}/test/invalid_file"
    .system.link
      source: "#{scratch}/test/valid_file"
      target: "#{scratch}/test/file_link"
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  describe 'error', ->

    they 'for invalid arguments', (ssh, next) ->
      # Test missing source
      mecano
        ssh: ssh
      .system.link
        target: __filename
      .then (err, changed) ->
        err.message.should.eql "Missing source, got undefined"
      .system.link # Test missing target
        source: __filename
      .then (err) ->
        err.message.should.eql "Missing target, got undefined"
      .then next
