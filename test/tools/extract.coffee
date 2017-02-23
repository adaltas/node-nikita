
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
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should see extension .zip', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.zip"
      target: scratch
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should see extension .tar.bz2', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tar.bz2"
      target: scratch
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should see extension .tar.xz', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tar.xz"
      target: scratch
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should validate a created file', (ssh, next) ->
    # Test with invalid creates option
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      creates: "#{scratch}/oh_no"
    .then (err, status) ->
      err.message.should.eql "Failed to create 'oh_no'"
    # Test with valid creates option
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      creates: "#{scratch}/a_dir"
    , (err, status) ->
      status.should.be.true() unless err
    .then next

  they 'should # option # unless_exists', (ssh, next) ->
    # Test with invalid creates option
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      unless_exists: __dirname
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'should pass error for invalid extension', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.extract
      source: __filename
      relax: true
    , (err) ->
      err.message.should.eql 'Unsupported extension, got ".coffee"'
    .then next

  they 'should pass error for missing source file', (ssh, next) ->
    mecano
      ssh: ssh
    .tools.extract
      source: '/does/not/exist.tgz'
      relax: true
    , (err) ->
      err.message.should.eql 'File does not exist: /does/not/exist.tgz'
    .then next

  they 'should strip component level 1', (ssh, next) ->
    # Test a non existing status dir
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      strip: 1
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_file"
    .then next
    
  they 'should strip component level 2', (ssh, next) ->
    # Test a non existing extracted dir
    mecano
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      strip: 2
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_file"
      not: true
    .then next
  
