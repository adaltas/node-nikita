
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
misc = require '../../src/misc'


describe 'system.tmpfs', ->
  config = test.config()
  return  unless config.isCentos6 or config.isCentos7
  scratch = test.scratch @
  describe 'generate without merge', ->
    return unless config.isCentos7
    they 'simple mount group configuration with target', (ssh, next) ->
      mecano
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
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        return next err if err
        fs.readFile "#{scratch}/file_1.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_1 0644 root root 10s -
          """
          next()
  
    
    they 'status not modified', (ssh, next) ->
      mecano
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
        return next err if err
        written.should.be.true()
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
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        fs.readFile "#{scratch}/file_1.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_1 0644 root root 10s -
          """
          next()
  
    they 'Override existing configuration file with target', (ssh, next) ->
      mecano
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
      .execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        fs.readFile "#{scratch}/file_1.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_2 0644 root root 10s -
          """
          next()
  
  describe 'generate with merge', ->
    return unless config.isCentos7
    they 'multiple file with target', (ssh, next) ->
      mecano
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
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        return next err if err
        fs.readFile "#{scratch}/file_2.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_2 0644 root root 10s -
            d /var/run/file_1 0644 root root 10s -
          """
          next()
    they 'multiple file merge status not modifed with target', (ssh, next) ->
      mecano
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
        written.should.be.false()
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      .execute
        cmd: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        return next err if err
        fs.readFile "#{scratch}/file_2.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_2 0644 root root 10s -
            d /var/run/file_1 0644 root root 10s -
          """
          next()

  describe 'default target Centos/Redhat 7', ->
    return unless config.isCentos7
    they 'simple mount group configuration', (ssh, next) ->
      mecano
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
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        return next err if err
        fs.readFile "/etc/tmpfiles.d/root.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_1 0644 root root 10s -
          """
          next()
          
    they 'simple mount group no uid', (ssh, next) ->
      mecano
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
        return next err if err
        written.should.be.true()
      .execute
        cmd: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
      , (err) ->
        return next err if err
        fs.readFile "/etc/tmpfiles.d/root.conf", 'utf8', (err, data) ->
          return next err if err
          data.should.eql """
            d /var/run/file_1 0644 root root 10s -
          """
          next()
  
  describe 'Os discovery', ->
    return unless config.isCentos6
    they 'detect Centos/Redhat 6 not supported', (ssh, next) ->
      mecano
        ssh: ssh
      .system.tmpfs
        mount: '/var/run/file_1'
        uid: 'root'
        gid: 'root'
        age: '10s'
        argu: '-'
        perm: '0644'
        merge: false
      , (err, written) ->
        err.message.should.eql 'tempfs not available on your OS'
        written.should.be.false()
        next()
