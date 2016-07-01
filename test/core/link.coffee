
fs = require 'fs'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'link', ->

  scratch = test.scratch @

  they 'should link file', (ssh, next) ->
    # Create a non existing link
    target = "#{scratch}/link_test"
    mecano
      ssh: ssh
    .link # Link does not exist
      source: __filename
      target: target
    , (err, linked) ->
      linked.should.be.true()
    .link # Link already exists
      source: __filename
      target: target
    , (err, linked) ->
      linked.should.be.false()
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
    .link # Link does not exist
      source: __dirname
      target: target
    , (err, linked) ->
      linked.should.be.true()
    .link # Link already exists
      ssh: ssh
      source: __dirname
      target: target
    , (err, linked) ->
      linked.should.be.false()
    .then (err) ->
      return next err if err
      fs.lstat ssh, target, (err, stat) ->
        stat.isSymbolicLink().should.be.true()
        next()
  
  they 'should create parent directories', (ssh, next) ->
    # Create a non existing link
    mecano.link
      ssh: ssh
      source: __dirname
      target: "#{scratch}/test/dir/link_test"
    , (err, linked) ->
      return next err if err
      linked.should.be.true()
      fs.lstat ssh, "#{scratch}/test/dir/link_test", (err, stat) ->
        stat.isSymbolicLink().should.be.true()
        # Test creating two identical parent dirs
        target = "#{scratch}/test/dir2"
        mecano.link [
          ssh: ssh
          source: "#{__dirname}/merge.coffee"
          target: "#{target}/merge.coffee"
        ,
          ssh: ssh
          source: "#{__dirname}/mkdir.coffee"
          target: "#{target}/mkdir.coffee"
        ], (err, linked) ->
          return next err if err
          linked.should.be.true()
        .then next

  they 'should override invalid link', (ssh, next) ->
    mecano
      ssh: ssh
    .write
      target: "#{scratch}/test/invalid_file"
      content: 'error'
    .write
      target: "#{scratch}/test/valid_file"
      content: 'ok'
    .link
      source: "#{scratch}/test/invalid_file"
      target: "#{scratch}/test/file_link"
    , (err, linked) ->
      linked.should.be.true() unless err
    .remove
      target: "#{scratch}/test/invalid_file"
    .link
      source: "#{scratch}/test/valid_file"
      target: "#{scratch}/test/file_link"
    , (err, linked) ->
      linked.should.be.true() unless err
    .then next

  describe 'error', ->

    they 'for invalid arguments', (ssh, next) ->
      # Test missing source
      mecano
        ssh: ssh
      .link
        target: __filename
      .then (err, changed) ->
        err.message.should.eql "Missing source, got undefined"
      .link # Test missing target
        source: __filename
      .then (err, linked) ->
        err.message.should.eql "Missing target, got undefined"
      .then next
