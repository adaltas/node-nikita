
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'tools.extract', ->

  they 'should see extension .tgz', (ssh) ->
    # Test a non existing extracted dir
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should see extension .zip', (ssh) ->
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.zip"
      target: scratch
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should see extension .tar.bz2', (ssh) ->
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tar.bz2"
      target: scratch
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should see extension .tar.xz', (ssh) ->
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tar.xz"
      target: scratch
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should validate a created file', (ssh) ->
    # Test with invalid creates option
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      creates: "#{scratch}/oh_no"
    .next (err, {status}) ->
      err.message.should.eql "Failed to create 'oh_no'"
    # Test with valid creates option
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      creates: "#{scratch}/a_dir"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'should # option # unless_exists', (ssh) ->
    # Test with invalid creates option
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      unless_exists: __dirname
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'should pass error for invalid extension', (ssh) ->
    nikita
      ssh: ssh
    .tools.extract
      source: __filename
      relax: true
    , (err) ->
      err.message.should.eql 'Unsupported extension, got ".coffee"'
    .promise()

  they 'should pass error for missing source file', (ssh) ->
    nikita
      ssh: ssh
    .tools.extract
      source: '/does/not/exist.tgz'
      relax: true
    , (err) ->
      err.message.should.eql 'File does not exist: /does/not/exist.tgz'
    .promise()

  they 'should strip component level 1', (ssh) ->
    # Test a non existing status dir
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      strip: 1
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_file"
    .promise()

  they 'should strip component level 2', (ssh) ->
    # Test a non existing extracted dir
    nikita
      ssh: ssh
    .tools.extract
      source: "#{__dirname}/../resources/a_dir.tgz"
      target: scratch
      strip: 2
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_file"
      not: true
    .promise()
  
