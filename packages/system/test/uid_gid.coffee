
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.uid_gid', ->
  return unless test.tags.system_user

  they 'convert names to id', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @system.user.remove 'toto'
      await @system.group.remove ['toto', 'lulu']
      await @system.group.remove 'lulu'
      await @system.group 'toto', gid: 1234
      await @system.group 'lulu', gid: 1235
      await @system.user 'toto', uid: 1234, gid: 1235
      {uid, gid, default_gid} = await @system.uid_gid
        uid: 'toto'
        gid: 'toto'
      uid.should.eql 1234
      gid.should.eql 1234
      default_gid.should.eql 1235

  they 'leave id untouched', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @file
        target: "#{tmpdir}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        users:x:994:monsieur
        """
      await @file
        target: "#{tmpdir}/etc/passwd"
        content: """
        root:x:0:0:root:/root:/bin/bash
        bin:x:1:1:bin:/bin:/usr/bin/nologin
        monsieur:x:99:99:monsieur:/:/home/monsieur
        """
      {$status, uid, gid} = await @system.uid_gid
        group_target: "#{tmpdir}/etc/group"
        passwd_target: "#{tmpdir}/etc/passwd"
        gid: '994'
        uid: '99'
      $status.should.be.false()
      uid.should.eql 99
      gid.should.eql 994

  they 'accept missing uid and gid', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @system.uid_gid
        group_target: "#{tmpdir}/etc/group"
        passwd_target: "#{tmpdir}/etc/passwd"
      .then ({$status, uid, gid}) ->
        $status.should.be.false()
        should(uid).be.undefined()
        should(gid).be.undefined()
  
