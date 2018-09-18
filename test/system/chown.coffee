
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.system_user

describe 'system.chown', ->

  they 'throw error if target does not exists', (ssh) ->
    nikita
      ssh: ssh
    .system.chown "#{scratch}/a_file", uid: 1234, gid: 1234, relax: true, (err) ->
      err.message.should.eql "Target Does Not Exist: \"#{scratch}/a_file\""
    .promise()

  they 'use stat shortcircuit', (ssh) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_file"
    .system.user.remove 'toto'
    .system.group.remove 'toto', gid: 1234
    .system.group 'toto', gid: 1234
    .system.user 'toto', uid: 1234, gid: 1234
    .fs.stat target: "#{scratch}/a_file", (err, {stats}) ->
      return if err
      logs = []
      @on 'text', (log) -> logs.push log
      @system.chown "#{scratch}/a_file", uid: 1234, gid: 1234, (err) ->
        logs.filter( (log) -> /^Stat /.test log.message ).length.should.eql 1 unless err
      @system.chown "#{scratch}/a_file", uid: 1234, gid: 1234, stats: stats, (err) ->
        logs.filter( (log) -> /^Stat /.test log.message ).length.should.eql 1 unless err
    .promise()

  they 'change uid and leave gid', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.user.remove 'lulu'
    .system.group.remove 'toto', gid: 1234
    .system.group.remove 'lulu', gid: 1235
    .system.group 'toto', gid: 1234
    .system.group 'lulu', gid: 1235
    .system.user 'toto', uid: 1234, gid: 1234
    .system.user 'lulu', uid: 1235, gid: 1235
    .file.touch "#{scratch}/a_file", uid: 'toto'
    .system.chown "#{scratch}/a_file", uid: 1235, (err, {status}) ->
      status.should.be.true() unless err
    .system.chown "#{scratch}/a_file", uid: 1235, (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      uid: 1235
      gid: 1234
    .promise()

  they 'change gid and leave uid', (ssh) ->
    nikita
      ssh: null
    .system.user.remove 'toto'
    .system.user.remove 'lulu'
    .system.group.remove 'toto', gid: 1234
    .system.group.remove 'lulu', gid: 1235
    .system.group 'toto', gid: 1234
    .system.group 'lulu', gid: 1235
    .system.user 'toto', uid: 1234, gid: 1234
    .file.touch "#{scratch}/a_file", uid: 'toto'
    .system.chown "#{scratch}/a_file", gid: 1235, (err, {status}) ->
      status.should.be.true() unless err
    .system.chown "#{scratch}/a_file", gid: 1235, (err, {status}) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/a_file"
      uid: 1234
      gid: 1235
    .promise()

  they 'detect status if uid is null', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.user.remove 'lulu'
    .system.group 'toto', gid: 1234
    .system.user 'toto', uid: 1234, gid: 1234
    .file.touch "#{scratch}/a_file", uid: 'toto', gid: 'toto'
    .system.chown "#{scratch}/a_file", uid: null, gid: 1234, (err, {status}) ->
      status.should.be.false() unless err
    .promise()
