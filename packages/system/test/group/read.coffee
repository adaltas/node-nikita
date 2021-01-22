
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'system.group.read', ->
  
  they 'shy doesnt modify the status', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}})->
      @file
        target: "#{tmpdir}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
      {status} = await @system.group.read
        target: "#{tmpdir}/etc/group"
      status.should.be.false()

  they 'activate locales', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}})->
      @file
        target: "#{tmpdir}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
      {groups} = await @system.group.read
        target: "#{tmpdir}/etc/group"
      groups.should.eql
        root: group: 'root', password: 'x', gid: 0, users: [ 'root' ]
        bin: group: 'bin', password: 'x', gid: 1, users: [ 'root', 'bin', 'daemon' ]
  
  describe 'option "gid"', ->
  
    they 'map a username to group record', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:wdavidw
          """
        {group} = await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: 'docker'
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'wdavidw' ]
    
    they 'map a gid to group record', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}})->
        @file
          target: "#{tmpdir}/etc/group"
          content: """
          root:x:0:root
          bin:x:1:root,bin,daemon
          docker:x:994:wdavidw
          """
        {group} = await @system.group.read
          target: "#{tmpdir}/etc/group"
          gid: '994'
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'wdavidw' ]
  
