
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'system.remove', ->
  
  they 'accept an option', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .system.remove
      source: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'accept a string', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .system.remove "#{scratch}/a_file", (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'accept an array of strings', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/file_1"
    .file.touch "#{scratch}/file_2"
    .system.remove [
      "#{scratch}/file_1"
      "#{scratch}/file_2"
    ], (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'a file', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    .system.remove
      source: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.remove
      source: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'a link', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .fs.symlink source: "#{scratch}/a_file", target: "#{scratch}/a_link"
    .system.remove
      source: "#{scratch}/a_link"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/a_link"
      not: true
    .promise()

  they 'use a pattern', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_dir/a_file"
    .file.touch "#{scratch}/a_dir.tar.gz"
    .file.touch "#{scratch}/a_dir.tz"
    .file.touch "#{scratch}/a_dir.zip"
    .system.remove
      source: "#{scratch}/*gz"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert "#{scratch}/a_dir.tar.gz", not: true
    .file.assert "#{scratch}/a_dir.tgz", not: true
    .file.assert "#{scratch}/a_dir.zip"
    .file.assert "#{scratch}/a_dir", type: 'directory'
    .promise()

  they 'a dir', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      target: "#{scratch}/remove_dir"
    .system.remove
      target: "#{scratch}/remove_dir"
    , (err, {status}) ->
      status.should.be.true() unless err
    .system.remove
      target: "#{scratch}/remove_dir"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
