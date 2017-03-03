
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.compress', ->

  scratch = test.scratch @

  they 'should see extension .tgz', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tgz"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tgz"
    .then next

  they 'should see extension .zip', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.zip"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.zip"
    .then next

  they 'should see extension .tar.bz2', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tar.bz2"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tar.bz2"
    .then next

  they 'should see extension .tar.xz', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/a_dir.tar.xz"
    , (err, status) ->
      status.should.be.true()
    .system.remove
      target: "#{scratch}/a_dir.tar.xz"
    .then next

  they 'should # option # unless_exists', (ssh, next) ->
    # Test with invalid creates option
    nikita
      ssh: ssh
    .tools.compress
      source: "#{__dirname}/../resources/a_dir"
      target: "#{scratch}/should_never_exists.tgz"
      unless_exists: __dirname
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'should pass error for invalid extension', (ssh, next) ->
    nikita
      ssh: ssh
    .tools.compress
      source: __filename
      target: __filename
      relax: true
    , (err) ->
      err.message.should.eql 'Unsupported extension, got ".coffee"'
    .then next
