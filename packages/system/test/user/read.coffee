
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.user.read', ->
  
  describe 'with option `target`', ->
    return unless test.tags.posix

    they 'shy doesnt modify the status', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          """
        {$status} = await @system.user.read
          target: "#{tmpdir}/etc/passwd"
        $status.should.be.false()

    they 'return all users', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          """
        await @system.user.read
          target: "#{tmpdir}/etc/passwd"
        .then ({users}) ->
          users.should.eql
            root: user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash'
            bin: user: 'bin', uid: 1, gid: 1, comment: 'bin', home: '/bin', shell: '/usr/bin/nologin'

  describe 'without option `target`', ->
    return unless test.tags.system_user

    they 'use `getent` without target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @system.user.remove 'toto'
        await @system.group.remove 'toto'
        await @system.user
          name: 'toto'
          system: true
          uid: 1010
        {user} = await @system.user.read
          uid: 'toto'
        user.should.match
          user: 'toto'
          uid: 1010
          comment: ''
          home: '/home/toto'
          shell: '/bin/sh'
        await @system.user.remove 'toto'
        await @system.group.remove 'toto'

  describe 'option "uid"', ->
    return unless test.tags.posix

    they 'map a username to group record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          nobody:x:99:99:nobody:/:/usr/bin/nologin
          """
        await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: 'nobody'
        .then ({user}) ->
          user.should.eql
            user: 'nobody'
            uid: 99
            gid: 99
            comment: 'nobody'
            home: '/'
            shell: '/usr/bin/nologin'

    they 'map a uid to user record', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:0:root:/root:/bin/bash
          bin:x:1:1:bin:/bin:/usr/bin/nologin
          nobody:x:99:99:nobody:/:/usr/bin/nologin
          """
        await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: '99'
        .then ({user}) ->
          user.should.eql
            user: 'nobody'
            uid: 99
            gid: 99
            comment: 'nobody'
            home: '/'
            shell: '/usr/bin/nologin'

    they 'throw error if uid is a username dont match any user', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: 'nobody'
        .should.be.rejectedWith
          message: 'Invalid Option: no uid matching "nobody"'
    
    they 'throw error if uid is an id dont match any user', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @file
          target: "#{tmpdir}/etc/passwd"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          """
        await @system.user.read
          target: "#{tmpdir}/etc/passwd"
          uid: '99'
        .should.be.rejectedWith
          message: 'Invalid Option: no uid matching 99'
