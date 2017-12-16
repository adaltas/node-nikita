
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'system.chown', ->

  config = test.config()
  return if config.disable_system_user
  scratch = test.scratch @
  
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
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) =>
        logs = []
        @on 'text', (log) -> logs.push log
        @system.chown "#{scratch}/a_file", uid: 1234, gid: 1234, (err) ->
          logs.filter( (log) -> /^Stat /.test log.message ).length.should.eql 1 unless err
        @system.chown "#{scratch}/a_file", uid: 1234, gid: 1234, stat: stat, (err) ->
          logs.filter( (log) -> /^Stat /.test log.message ).length.should.eql 1 unless err
        @next callback
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
    .system.chown "#{scratch}/a_file", uid: 1235, (err, status) ->
      status.should.be.true() unless err
    .system.chown "#{scratch}/a_file", uid: 1235, (err, status) ->
      status.should.be.false() unless err
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        stat.uid.should.eql 1235 unless err
        stat.gid.should.eql 1234 unless err
        callback err
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
    .system.chown "#{scratch}/a_file", gid: 1235, (err, status) ->
      status.should.be.true() unless err
    .system.chown "#{scratch}/a_file", gid: 1235, (err, status) ->
      status.should.be.false() unless err
    .call (_, callback) ->
      fs.stat ssh, "#{scratch}/a_file", (err, stat) ->
        stat.uid.should.eql 1234 unless err
        stat.gid.should.eql 1235 unless err
        callback err
    .promise()

  they 'detect status if uid is null', (ssh) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.user.remove 'lulu'
    .system.group 'toto', gid: 1234
    .system.user 'toto', uid: 1234, gid: 1234
    .file.touch "#{scratch}/a_file", uid: 'toto', gid: 'toto'
    .system.chown "#{scratch}/a_file", uid: null, gid: 1234, (err, status) ->
      status.should.be.false() unless err
    .promise()
