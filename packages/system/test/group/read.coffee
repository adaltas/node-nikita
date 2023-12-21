
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.group.read', ->
  
  describe 'with option `target`', ->
    return unless test.tags.posix
  
    they 'shy doesnt modify the status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        await @system.group.read
          target: "#{tmpdir}/etc/group"
        .then ({$status}) ->
          $status.should.be.false()

    they 'activate locales', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        await @system.group.read
          target: "#{tmpdir}/etc/group"
        .then ({groups}) ->
          groups.should.eql
            root: group: 'root', password: 'x', gid: 0, users: [ 'root' ]
            bin: group: 'bin', password: 'x', gid: 1, users: [ 'root', 'bin', 'daemon' ]

  describe 'without option `target`', ->
    return unless test.tags.system_user

    they 'use `getent` without target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @system.group.remove 'toto'
        await @system.group
          name: 'toto'
          gid: 1010
        await @system.group.read
          gid: 'toto'
        .then ({group}) ->
          group.should.match
            group: 'toto'
            password: 'x'
            gid: 1010
            users: []
        await @system.group.remove 'toto'
  
  describe 'option "gid"', ->
    return unless test.tags.posix
  
    they 'map a username to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:monsieur
          """
        await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: 'docker'
        .then ({group}) ->
          group.should.eql
            group: 'docker'
            password: 'x'
            gid: 994
            users: [ 'monsieur' ]
    
    they 'map a gid to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:monsieur
          """
        await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: '994'
        .then ({group}) ->
          group.should.eql
            group: 'docker'
            password: 'x'
            gid: 994
            users: [ 'monsieur' ]
  
