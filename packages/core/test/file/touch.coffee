
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.touch', ->
  
  they 'as a target option', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.touch
      target: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .promise()

  they 'as a string', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file", (err, {status}) ->
      status.should.be.true() unless err
    .file.touch "#{scratch}/a_file", (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .promise()

  they 'as an array of strings', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch [
      "#{scratch}/file_1"
      "#{scratch}/file_2"
    ], (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/file_1"
      content: ''
    .file.assert
      target: "#{scratch}/file_2"
      content: ''
    .promise()

  they 'an existing file', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.true()
    .file.touch
      target: "#{scratch}/a_file"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'valid default permissions', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
    .file.assert
      target: "#{scratch}/a_file"
      mode: 0o0644
    .promise()

  they 'change permissions', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o0700
    .file.assert
      target: "#{scratch}/a_file"
      mode: 0o0700
    .promise()

  they 'do not change permissions on existing file if not specified', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_file"
      mode: 0o666
    .file.touch
      target: "#{scratch}/a_file"
    .file.assert
      target: "#{scratch}/a_file"
      mode: 0o0666
    .promise()

  they 'create valid parent dir', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/subdir/a_file"
      mode:'0640'
    .file.assert
      target: "#{scratch}/subdir"
      mode: 0o0751
    .promise()

  they 'modify time but not status', ({ssh}) ->
    stat_org = null
    stat_new = null
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .call (_, callback) ->
      @fs.stat target: "#{scratch}/a_file", (err, {stats}) ->
        stat_org = stats
        callback err
    # Bypass fs cache, a value of 500 is not always enough
    .call (_, callback) -> setTimeout callback, 1000
    .file.touch "#{scratch}/a_file", (err, {status}) ->
      status.should.be.false()
    .call (_, callback) ->
      @fs.stat target: "#{scratch}/a_file", (err, {stats}) ->
        stat_new = stats
        callback err
    .call ->
      stat_org.mtime.should.not.eql stat_new.mtime
    .promise()
