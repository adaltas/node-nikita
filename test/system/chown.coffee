
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'fs'

describe 'system.chown', ->

  scratch = test.scratch @

  they 'change uid and leave gid', (ssh, next) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.user.remove 'lulu'
    .system.group 'toto', gid: 1234
    .system.group 'lulu', gid: 1235
    .system.user.add 'toto', uid: 1234, gid: 1234
    .system.user.add 'lulu', uid: 1235, gid: 1235
    .file.touch "#{scratch}/a_file", uid: 'toto'
    .system.chown "#{scratch}/a_file", uid: 1235
    .call (_, callback) ->
      fs.stat "#{scratch}/a_file", (err, stat) ->
        stat.uid.should.eql 1235
        stat.gid.should.eql 1234
        callback()
    .then next
