
mecano = require '../../src'
they = require 'ssh2-they'
test = require '../test'
fs = require 'ssh2-fs'

describe 'extract', ->

  scratch = test.scratch @

  they 'should see extension .tgz', (ssh, next) ->
    # Test a non existing extracted dir
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
    , (err, extracted) ->
      extracted.should.be.true()
    .then next

  they 'should see extension .zip', (ssh, next) ->
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.zip"
      destination: scratch
    , (err, extracted) ->
      extracted.should.be.true()
    .then next

  they 'should see extension .tar.bz2', (ssh, next) ->
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tar.bz2"
      destination: scratch
    , (err, extracted) ->
      extracted.should.be.true()
    .then next

  they 'should see extension .tar.xz', (ssh, next) ->
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tar.xz"
      destination: scratch
    , (err, extracted) ->
      extracted.should.be.true()
    .then next

  they 'should validate a created file', (ssh, next) ->
    # Test with invalid creates option
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      creates: "#{scratch}/oh_no"
    .then (err, extracted) ->
      err.message.should.eql "Failed to create 'oh_no'"
      # Test with valid creates option
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      creates: "#{scratch}/a_dir"
    , (err, extracted) ->
      extracted.should.be.true()
    .then next

  they 'should # option # unless_exists', (ssh, next) ->
    # Test with invalid creates option
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      unless_exists: __dirname
    , (err, extracted) ->
      return next err if err
      extracted.should.be.false()
      next()

  they 'should pass error for invalid extension', (ssh, next) ->
    mecano.extract
      ssh: ssh
      source: __filename
    , (err, extracted) ->
      err.message.should.eql 'Unsupported extension, got ".coffee"'
      next()

  they 'should pass error for missing source file', (ssh, next) ->
    mecano.extract
      ssh: ssh
      source: '/does/not/exist.tgz'
    , (err, extracted) ->
      err.message.should.eql 'File does not exist: /does/not/exist.tgz'
      next()

  they 'should strip component level 1', (ssh, done) ->
    # Test a non existing extracted dir
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      strip: 1
    , (err, extracted) ->
      extracted.should.be.true()
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        return done err if err
        exists.should.be.true()
        done()
    
  they 'should strip component level 2', (ssh, done) ->
    # Test a non existing extracted dir
    mecano
      ssh: ssh
    .extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      strip: 2
    , (err, extracted) ->
      extracted.should.be.true()
      fs.exists ssh, "#{scratch}/a_file", (err, exists) ->
        return done err if err
        exists.should.be.false()
        done()
  
