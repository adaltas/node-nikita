
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
they = require 'ssh2-they'
test = require './test'

describe 'extract', ->

  scratch = test.scratch @

  they 'should see extension .tgz', (ssh, next) ->
    # Test a non existing extracted dir
    mecano.extract
      ssh: ssh
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
    , (err, extracted) ->
      return next err if err
      extracted.should.be.ok
      # Test an existing extracted dir
      # Note, there is no way for us to know which directory
      # it is in advance
      mecano.extract
        ssh: ssh
        source: "#{__dirname}/../resources/a_dir.tgz"
        destination: scratch
      , (err, extracted) ->
        return next err if err
        extracted.should.be.ok
        next()
  
  they 'should see extension .zip', (ssh, next) ->
    # Test a non existing extracted dir
    mecano.extract
      ssh: ssh
      source: "#{__dirname}/../resources/a_dir.zip"
      destination: scratch
    , (err, extracted) ->
      return next err if err
      extracted.should.be.ok
      # Test an existing extracted dir
      # Note, there is no way for us to know which directory
      # it is in advance
      mecano.extract
        ssh: ssh
        source: "#{__dirname}/../resources/a_dir.zip"
        destination: scratch
      , (err, extracted) ->
        return next err if err
        extracted.should.be.ok
        next()
  
  they 'should validate a created file', (ssh, next) ->
    # Test with invalid creates option
    mecano.extract
      ssh: ssh
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      creates: "#{scratch}/oh_no"
    , (err, extracted) ->
      err.message.should.eql "Failed to create 'oh_no'"
      # Test with valid creates option
      mecano.extract
        ssh: ssh
        source: "#{__dirname}/../resources/a_dir.tgz"
        destination: scratch
        creates: "#{scratch}/a_dir"
      , (err, extracted) ->
        return next err if err
        extracted.should.be.ok
        next()
  
  they 'should # option # not_if_exists', (ssh, next) ->
    # Test with invalid creates option
    mecano.extract
      ssh: ssh
      source: "#{__dirname}/../resources/a_dir.tgz"
      destination: scratch
      not_if_exists: __dirname
    , (err, extracted) ->
      return next err if err
      extracted.should.not.be.ok
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


