
fs = require 'fs'
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
misc = require '../../src/misc'

describe 'cgroups', ->
  
  config = test.config()
  return unless config.isCentos6 or config.isCentos7
  scratch = test.scratch @
  
  describe 'generate without merge', ->
    mounts = [
      type: 'cpuset', path: '/cgroup/cpuset'
    ,
      type: 'cpu', path: '/cgroup/cpu'
    ,
      type: 'cpuacct', path: '/cgroup/cpuacct'
    ,
      type: 'memory', path: '/cgroup/memory'
    ,
      type: 'devices', path: '/cgroup/devices'
    ]
    groups =
      toto:
        perm: 
          admin: uid: 'toto', gid: 'toto'
          task: uid: 'toto', gid: 'toto'
        cpu: 
          'cpu.rt_period_us': '"1000000"'
          'cpu.rt_runtime_us': '"0"'
          'cpu.cfs_period_us': '"100000"'
    def =
      perm: 
        admin:
          uid: 'toto'
          gid: 'toto'
        task:
          uid: 'toto'
          gid: 'toto'
      cpu: 
        'cpu.rt_period_us': '"1000000"'
        'cpu.rt_runtime_us': '"0"'
        'cpu.cfs_period_us': '"100000"'
    they 'simple mount group configuration file', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_mount_only.cgconfig.conf"
        mode: 0o0754
        mounts: mounts
        merge:false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file_mount_only.cgconfig.conf"
        content:  """
          mount {
            cpuset = /cgroup/cpuset;
            cpu = /cgroup/cpu;
            cpuacct = /cgroup/cpuacct;
            memory = /cgroup/memory;
            devices = /cgroup/devices;
          }
        """
      .then next
    they 'simple cgroup configuration file', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_cgroup_only.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file_cgroup_only.cgconfig.conf"
        content: """
          group toto {
            perm {
              admin {
                uid = toto;
                gid = toto;
              }
              task {
                uid = toto;
                gid = toto;
              }
            }
            cpu {
              cpu.rt_period_us = "1000000";
              cpu.rt_runtime_us = "0";
              cpu.cfs_period_us = "100000";
            }
          }
        """
      .then next
    they 'default only configuration file', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_default_only.cgconfig.conf"
        mode: 0o0754
        default: def
        merge: false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file_default_only.cgconfig.conf"
        content: """
          default {
            perm {
              admin {
                uid = toto;
                gid = toto;
              }
              task {
                uid = toto;
                gid = toto;
              }
            }
            cpu {
              cpu.rt_period_us = "1000000";
              cpu.rt_runtime_us = "0";
              cpu.cfs_period_us = "100000";
            }
          }
        """
      .then next
    they 'complete configuration file', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_complete.cgconfig.conf"
        mode: 0o0754
        default: def
        groups: groups
        mounts: mounts
        merge: false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_file_complete.cgconfig.conf"
        content: """
          mount {
            cpuset = /cgroup/cpuset;
            cpu = /cgroup/cpu;
            cpuacct = /cgroup/cpuacct;
            memory = /cgroup/memory;
            devices = /cgroup/devices;
          }
          group toto {
            perm {
              admin {
                uid = toto;
                gid = toto;
              }
              task {
                uid = toto;
                gid = toto;
              }
            }
            cpu {
              cpu.rt_period_us = "1000000";
              cpu.rt_runtime_us = "0";
              cpu.cfs_period_us = "100000";
            }
          }
          default {
            perm {
              admin {
                uid = toto;
                gid = toto;
              }
              task {
                uid = toto;
                gid = toto;
              }
            }
            cpu {
              cpu.rt_period_us = "1000000";
              cpu.rt_runtime_us = "0";
              cpu.cfs_period_us = "100000";
            }
          }
        """
      .then next
    they 'status not modifed', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_complete.cgconfig.conf"
        mode: 0o0754
        default: def
        groups: groups
        mounts: mounts
        merge: false
      .system.cgroups
        target: "#{scratch}/a_file_complete.cgconfig.conf"
        mode: 0o0754
        default: def
        groups: groups
        mounts: mounts
        merge: false
      , (err, status) ->
        status.should.be.false() unless err
      .then next

  describe 'generate with merge', ->
    mounts = [
        type: 'cpuset'
        path: '/cgroup/cpuset'
      ,
        type: 'cpu', path: '/cgroup/cpu'
      ,
        type: 'cpuacct', path: '/cgroup/cpuacct'
      ,
        type: 'memory', path: '/cgroup/memory'
      ,
        type: 'devices', path: '/cgroup/devices'
      ]
    groups =
      toto:
        perm: 
          admin: uid: 'toto', gid: 'toto'
          task: uid: 'toto', gid: 'toto'
        cpu: 
          'cpu.rt_period_us': '"1000000"'
          'cpu.rt_runtime_us': '"0"'
          'cpu.cfs_period_us': '"100000"'
    def =
      perm: 
        admin: uid: 'toto', gid: 'toto'
        task: uid: 'toto', gid: 'toto'
      cpu: 
        'cpu.rt_period_us': '"1000000"'
        'cpu.rt_runtime_us': '"0"'
        'cpu.cfs_period_us': '"100000"'
    they 'read mount from system and merge group', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_merge_mount_groups.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: true
      , (err, status) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        fs.readFile "#{scratch}/a_file_merge_mount_groups.cgconfig.conf", 'utf8', (err, data) ->
          return callback err if err
          content = misc.cgconfig.parse data
          content.mounts.should.not.be.empty()
          content.groups.should.eql groups
          callback()
      .then next
    they 'status not modified', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_merge_mount_groups.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: true
      .system.cgroups
        target: "#{scratch}/a_file_merge_mount_groups.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: true
      , (err, status) ->
        status.should.be.false() unless err
      .then next

  describe 'centos only', ->
    they 'cache system type', (ssh, next) ->
      mecano
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_merge_mount_groups.cgconfig.conf"
        mode: 0o0754
        groups: toto:
          perm: 
            admin: uid: 'toto', gid: 'toto'
            task: uid: 'toto', gid: 'toto'
          cpu: 
            'cpu.rt_period_us': '"1000000"'
            'cpu.rt_runtime_us': '"0"'
            'cpu.cfs_period_us': '"100000"'
        merge: true
      .call (options) ->
        options.store['mecano:system:type'].should.match /^((redhat)|(centos))/
      .then next
      
