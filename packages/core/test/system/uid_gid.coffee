
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.system_user

describe 'system.uid_gid', ->

  they 'convert names to id', ({ssh}) ->
    nikita
      ssh: ssh
    .system.user.remove 'toto'
    .system.group.remove ['toto', 'lulu']
    .system.group.remove 'lulu'
    .system.group 'toto', gid: 1234
    .system.group 'lulu', gid: 1235
    .system.user 'toto', uid: 1234, gid: 1235
    .system.uid_gid
      uid: 'toto'
      gid: 'toto'
    , (err, {status, uid, gid, default_gid}) ->
      throw err if err
      status.should.be.true()
      uid.should.eql 1234
      gid.should.eql 1234
      default_gid.should.eql 1235
    .promise()

  they 'leave id untouched', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      users:x:994:wdavidw
      """
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      wdavidw:x:99:99:wdavidw:/:/home/wdavidw
      """
    .system.uid_gid
      group_target: "#{scratch}/etc/group"
      passwd_target: "#{scratch}/etc/passwd"
      gid: '994'
      uid: '99'
    , (err, {status, uid, gid}) ->
      throw err if err
      status.should.be.false()
      uid.should.eql 99
      gid.should.eql 994
    .promise()

  they 'accept missing uid and gid', ({ssh}) ->
    nikita
      ssh: ssh
    .system.uid_gid
      group_target: "#{scratch}/etc/group"
      passwd_target: "#{scratch}/etc/passwd"
    , (err, {status, uid, gid}) ->
      throw err if err
      status.should.be.false()
      (uid is undefined).should.be.true()
      (gid is undefined).should.be.true()
    .promise()
  
