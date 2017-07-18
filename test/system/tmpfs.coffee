
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'
misc = require '../../src/misc'


describe 'system.tmpfs', ->
  
  scratch = test.scratch @
  config = test.config()
  return  if config.disable_system_tmpfs
  
  describe 'generate without merge', ->
    
    they 'simple mount group configuration with target', (ssh) ->
      nikita
        ssh: ssh
      .system.remove
        target: "#{scratch}/file_1.conf"
      .system.tmpfs
        target: "#{scratch}/file_1.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: "#{scratch}/file_1.conf"
        content: """
          d /var/run/file_1 0644 root root 10s -
        """
      .promise()

    they 'status not modified', (ssh) ->
      nikita
        ssh: ssh
      .system.tmpfs
        target: "#{scratch}/file_1.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        written.should.be.true() unless true
      .system.tmpfs
        target: "#{scratch}/file_1.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.false()
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: "#{scratch}/file_1.conf"
        content: """
          d /var/run/file_1 0644 root root 10s -
        """
      .promise()
  
    they 'Override existing configuration file with target', (ssh) ->
      nikita
        ssh: ssh
      .system.remove
        target: "#{scratch}/file_1.conf"
      .system.tmpfs
        target: "#{scratch}/file_1.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.tmpfs
        target: "#{scratch}/file_1.conf"
        mount: '/var/run/file_2'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: "#{scratch}/file_1.conf"
        content: """
          d /var/run/file_2 0644 root root 10s -
        """
      .promise()
  
  describe 'generate with merge', ->
    
    they 'multiple file with target', (ssh) ->
      nikita
        ssh: ssh
      .system.remove
        target: "#{scratch}/file_2.conf"
      .system.tmpfs
        target: "#{scratch}/file_2.conf"
        mount: '/var/run/file_2'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.tmpfs
        target: "#{scratch}/file_2.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: true
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .system.execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: "#{scratch}/file_2.conf"
        content: """
          d /var/run/file_2 0644 root root 10s -
          d /var/run/file_1 0644 root root 10s -
        """
      .promise()

    they 'multiple file merge status not modifed with target', (ssh) ->
      nikita
        ssh: ssh
      .system.remove
        target: "#{scratch}/file_2.conf"
      .system.tmpfs
        target: "#{scratch}/file_2.conf"
        mount: '/var/run/file_2'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        written.should.be.true() unless err
      .system.tmpfs
        target: "#{scratch}/file_2.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: true
      , (err, written) ->
        written.should.be.true() unless err
      .system.tmpfs
        target: "#{scratch}/file_2.conf"
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: true
      , (err, written) ->
        written.should.be.false() unless err
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .system.execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: "#{scratch}/file_2.conf"
        content: """
          d /var/run/file_2 0644 root root 10s -
          d /var/run/file_1 0644 root root 10s -
        """
      .promise()

  describe 'default target Centos/Redhat 7', ->
    
    they 'simple mount group configuration', (ssh) ->
      nikita
        ssh: ssh
      .system.remove
        target: "/etc/tmpfiles.d/root.conf"
      .system.tmpfs
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        return next err if err
        written.should.be.true()
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: '/etc/tmpfiles.d/root.conf'
        content: "d /var/run/file_1 0644 root root 10s -"
      .promise()

    they 'simple mount group no uid', (ssh) ->
      nikita
        ssh: ssh
      .system.remove '/etc/tmpfiles.d/root.conf'
      .system.tmpfs
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        written.should.be.true() unless err
      .system.execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .file.assert
        target: '/etc/tmpfiles.d/root.conf'
        content: "d /var/run/file_1 0644 root root 10s -"
      .promise()
