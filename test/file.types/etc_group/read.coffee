
nikita = require '../../../src'
test = require '../../test'
they = require 'ssh2-they'

describe 'file.types.etc_group.read', ->

  scratch = test.scratch @

  they 'activate locales', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .file.types.etc_group.read
      target: "#{scratch}/etc/group"
    , (err, status, groups) ->
      throw err if err
      groups.should.eql
        root: group: 'root', password: 'x', gid: 0, user_list: [ 'root' ]
        bin: group: 'bin', password: 'x', gid: 1, user_list: [ 'root', 'bin', 'daemon' ]
    .promise()
  
  they 'option gid map a username to group record', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      docker:x:994:wdavidw
      """
    .file.types.etc_group.read
      target: "#{scratch}/etc/group"
      gid: 'docker'
    , (err, status, group) ->
      throw err if err
      group.should.eql group: 'docker', password: 'x', gid: 994, user_list: [ 'wdavidw' ]
    .promise()
  
  they 'option gid map a gid to group record', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      docker:x:994:wdavidw
      """
    .file.types.etc_group.read
      target: "#{scratch}/etc/group"
      gid: '994'
    , (err, status, group) ->
      throw err if err
      group.should.eql group: 'docker', password: 'x', gid: 994, user_list: [ 'wdavidw' ]
    .promise()

  they 'option cache is disabled by default', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .file.types.etc_group.read
      target: "#{scratch}/etc/group"
    , (err, status, groups) ->
      throw err if err
      (@store['nikita:etc_group'] is undefined).should.be.true()
    .promise()

  they 'option cache place group in store', (ssh) ->
    logs = []
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/group"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .file.types.etc_group.read
      target: "#{scratch}/etc/group"
      cache: true
    , (err, status, groups) ->
      throw err if err
      @store['nikita:etc_group'].should.eql groups
    .file.types.etc_group.read
      log: (log) -> logs.push log
      target: "#{scratch}/etc/group"
      cache: true
    , (err, status, groups) ->
      throw err if err
      logs.some( (log) -> log.message is 'Get group definition from cache' ).should.be.true()
    .promise()
      
