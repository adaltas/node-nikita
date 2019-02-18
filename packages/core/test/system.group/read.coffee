
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'system.group.read', ->
  
  they 'shy doesnt modify the status', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .system.group.read
      target: "#{scratch}/etc/group"
    , (err, {status}) ->
      status.should.be.false() unless err
    .next (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'activate locales', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .system.group.read
      target: "#{scratch}/etc/group"
    , (err, {groups}) ->
      throw err if err
      groups.should.eql
        root: group: 'root', password: 'x', gid: 0, users: [ 'root' ]
        bin: group: 'bin', password: 'x', gid: 1, users: [ 'root', 'bin', 'daemon' ]
    .promise()
  
  describe 'option "gid"', ->
  
    they 'map a username to group record', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        docker:x:994:wdavidw
        """
      .system.group.read
        target: "#{scratch}/etc/group"
        gid: 'docker'
      , (err, {group}) ->
        throw err if err
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'wdavidw' ]
      .promise()
    
    they 'map a gid to group record', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        docker:x:994:wdavidw
        """
      .system.group.read
        target: "#{scratch}/etc/group"
        gid: '994'
      , (err, {group}) ->
        throw err if err
        group.should.eql group: 'docker', password: 'x', gid: 994, users: [ 'wdavidw' ]
      .promise()
  
  describe 'option "cache"', ->

    they 'option cache is disabled by default', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
      .system.group.read
        target: "#{scratch}/etc/group"
      , (err, {groups}) ->
        throw err if err
        (@store['nikita:etc_group'] is undefined).should.be.true()
      .promise()

    they 'option cache place group in store', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
      .system.group.read
        target: "#{scratch}/etc/group"
        cache: true
      , (err, {groups}) ->
        throw err if err
        @store['nikita:etc_group'].should.eql groups
      .system.group.read
        log: (log) -> logs.push log
        target: "#{scratch}/etc/group"
        cache: true
      , (err, {groups}) ->
        throw err if err
        logs.some( (log) -> log.message is 'Get group definition from cache' ).should.be.true()
      .promise()
  
  describe 'option "log"', ->

    they 'can be true, false, undefined', ({ssh}) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push log
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
        log: false
      # Value true enable logs
      .system.group.read
        target: "#{scratch}/etc/group"
        log: true
      , (err) ->
        logs.some( (log) -> log.message is 'Entering fs.readFile').should.be.true() unless err
        logs = []
      # Value undefined disable logs
      .system.group.read
        target: "#{scratch}/etc/group"
        log: undefined
      , (err) ->
        logs.some( (log) -> log.message is 'Entering fs.readFile').should.not.be.true() unless err
      # Value false disable logs
      .system.group.read
        target: "#{scratch}/etc/group"
        log: false
      , (err) ->
        logs.some( (log) -> log.message is 'Entering fs.readFile').should.not.be.true() unless err
      .promise()
    
    they 'honor cascading', ({ssh}) ->
      # Well, this is arguably a good or a bad idea
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) -> logs.push log
      .file
        target: "#{scratch}/etc/group"
        content: """
        root:x:0:root
        bin:x:1:root,bin,daemon
        """
        log: false
      # Value undefined preserve default behavior
      .call log: true, ->
        @system.group.read
          target: "#{scratch}/etc/group"
          log: undefined
        , (err) ->
          logs.some( (log) -> log.message is 'Entering fs.readFile').should.be.true() unless err
      .call -> logs = []
      .call log: false, ->
        @system.group.read
          target: "#{scratch}/etc/group"
          log: undefined
        , (err) ->
          logs.some( (log) -> log.message is 'Entering fs.readFile').should.not.be.true() unless err
      .promise()
    
