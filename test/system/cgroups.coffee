
fs = require 'fs'
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.system_cgroups

describe 'system.cgroups', ->
  
  describe 'generate without merge', ->
    
    mounts = [
      { type: 'cpuset', path: '/cgroup/cpuset' }
      { type: 'cpu', path: '/cgroup/cpu' }
      { type: 'cpuacct', path: '/cgroup/cpuacct' }
      { type: 'memory', path: '/cgroup/memory' }
      { type: 'devices', path: '/cgroup/devices' }
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
    
    they 'simple mount group configuration file', (ssh) ->
      nikita
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_mount_only.cgconfig.conf"
        mode: 0o0754
        mounts: mounts
        merge:false
      , (err, {status}) ->
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
      .promise()
    
    they 'simple cgroup configuration file', (ssh) ->
      nikita
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_cgroup_only.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: false
      , (err, {status}) ->
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
      .promise()
      
    they 'default only configuration file', (ssh) ->
      nikita
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_default_only.cgconfig.conf"
        mode: 0o0754
        default: def
        merge: false
      , (err, {status}) ->
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
      .promise()
    
    they 'complete configuration file', (ssh) ->
      nikita
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_complete.cgconfig.conf"
        mode: 0o0754
        default: def
        groups: groups
        mounts: mounts
        merge: false
      , (err, {status}) ->
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
      .promise()

    they 'status not modifed', (ssh) ->
      nikita
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
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

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
    
    they 'read mount from system and merge group', (ssh) ->
      nikita
        ssh: ssh
      .system.cgroups
        target: "#{scratch}/a_file_merge_mount_groups.cgconfig.conf"
        mode: 0o0754
        groups: groups
        merge: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .call (_, callback) ->
        fs.readFile "#{scratch}/a_file_merge_mount_groups.cgconfig.conf", 'utf8', (err, data) ->
          return callback err if err
          data = misc.cgconfig.parse data
          data.mounts.should.not.be.empty()
          data.groups.should.eql groups
          callback()
      .promise()
    
    they 'status not modified', (ssh) ->
      nikita
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
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()

  describe 'centos only', ->
    
    they 'cache system type', (ssh) ->
      nikita
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
      .call ->
        @store['nikita:system:type'].should.match /^((redhat)|(centos))/
      .promise()

    they 'get cgroups attributes', (ssh) ->
      nikita
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
      , (err, {status, cgroups}) ->
        cgroups['cpu_path'].should.match /^((\/sys\/fs\/cgroup\/cpu)|(\/cgroups\/cpu))/
        cgroups['mount'].should.match /^((\/sys\/fs\/cgroup)|(\/cgroups))/
      .promise()
