
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.system_user

describe 'system.user', ->
  
  they 'accept only user name', ({ssh}) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', (err, {status}) ->
      status.should.be.true() unless err
    .system.user 'toto', (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'created with a uid', ({ssh}) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', uid: 1234, (err, {status}) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, {status}) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, {status}) ->
      status.should.be.false() unless err
    .system.user 'toto', (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'created without a uid', ({ssh}) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.user 'toto', (err, {status}) ->
      status.should.be.true() unless err
    .system.user 'toto', uid: 1235, (err, {status}) ->
      status.should.be.true() unless err
    .system.user 'toto', (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'parent home does not exist', ({ssh}) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove 'toto'
    .system.remove "#{scratch}/toto/subdir"
    .system.user 'toto', home: "#{scratch}/toto/subdir", (err, {status}) ->
      status.should.be.true() unless err
    .file.assert "#{scratch}/toto",
      mode: 0o0644
      uid: 0
      gid: 0
    .promise()
