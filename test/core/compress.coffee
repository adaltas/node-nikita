
mecano = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'compress', ->

  scratch = test.scratch @

  they 'should see extension .tgz', (ssh, next) ->
    mecano
      ssh: ssh
    .compress
      source: "#{__dirname}/../resources/a_dir"
      destination: "#{scratch}/a_dir.tgz"
    , (err, compressed) ->
      compressed.should.be.true()
    .remove
      destination: "#{scratch}/a_dir.tgz"
    .then next

  they 'should see extension .zip', (ssh, next) ->
    mecano
      ssh: ssh
    .compress
      source: "#{__dirname}/../resources/a_dir"
      destination: "#{scratch}/a_dir.zip"
    , (err, compressed) ->
      compressed.should.be.true()
    .remove
      destination: "#{scratch}/a_dir.zip"
    .then next

  they 'should see extension .tar.bz2', (ssh, next) ->
    mecano
      ssh: ssh
    .compress
      source: "#{__dirname}/../resources/a_dir"
      destination: "#{scratch}/a_dir.tar.bz2"
    , (err, compressed) ->
      compressed.should.be.true()
    .remove
      destination: "#{scratch}/a_dir.tar.bz2"
    .then next

  they 'should see extension .tar.xz', (ssh, next) ->
    mecano
      ssh: ssh
    .compress
      source: "#{__dirname}/../resources/a_dir"
      destination: "#{scratch}/a_dir.tar.xz"
    , (err, compressed) ->
      compressed.should.be.true()
    .remove
      destination: "#{scratch}/a_dir.tar.xz"
    .then next

  they 'should # option # unless_exists', (ssh, next) ->
    # Test with invalid creates option
    mecano
      ssh: ssh
    .compress
      source: "#{__dirname}/../resources/a_dir"
      destination: "#{scratch}/should_never_exists.tgz"
      unless_exists: __dirname
    , (err, compressed) ->
      return next err if err
      compressed.should.be.false()
      next()

  they 'should pass error for invalid extension', (ssh, next) ->
    mecano
      ssh: ssh
    .extract
      source: __filename
      destination: __filename
    , (err, compressed) ->
      err.message.should.eql 'Unsupported extension, got ".coffee"'
      next()
