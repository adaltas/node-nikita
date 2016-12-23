
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'misc', ->

  scratch = test.scratch @

  describe 'array', ->

    it 'intersect', ->
      misc.array.intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
      misc.array.intersect(['a', 'c', 'd'], []).should.eql []
      misc.array.intersect([], ['e', 'd', 'c']).should.eql []

    it 'unique', ->
      misc.array.unique(['a', 'b', 'c', 'a']).should.eql ['a', 'b', 'c']

    it 'merge', ->
      misc.array.merge(['a', 'b'], ['c', 'a']).should.eql ['a', 'b', 'c', 'a']

  describe 'object', ->

    describe 'equals', ->

      it 'two objects', ->
        misc.object.equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true()
        misc.object.equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false()
        misc.object.equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true()
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true()
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false()

    describe 'diff', ->

      it 'two objects', ->
        misc.object.diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.eql {}
        misc.object.diff({a: '1', b: '21', c: '3'}, {a: '1', b: '22', c: '3'}, ['a', 'c']).should.eql {}
        misc.object.diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}, ['a', 'c']).should.eql {'a': ['11', '12']}

      it 'two objects without keys', ->
        misc.object.diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}).should.eql {}
        misc.object.diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}).should.eql {'a': ['11', '12']}

  describe 'cgconfig', ->
    it 'parse mount only file', ->
      mount_obj = """
        mount {
          cpuset = /cgroup/cpuset;
          cpu = /cgroup/cpu;
          cpuacct = /cgroup/cpuacct;
          memory = /cgroup/memory;
          devices = /cgroup/devices;
        }
      """
      misc.cgconfig.parse(mount_obj).should.eql {
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ]
        groups: {}
      }
    it 'parse multiple file', ->
      mount_obj = """
        mount {
          cpuset = /cgroup/cpuset;
          cpu = /cgroup/cpu;
          cpuacct = /cgroup/cpuacct;
          memory = /cgroup/memory;
          devices = /cgroup/devices;
        }
        mount {
          cpuset = /cgroup/cpusetbis;
          cpu = /cgroup/cpubis;
          cpuacct = /cgroup/cpuacctbis;
          memory = /cgroup/memorybis;
          devices = /cgroup/devicesbis;
        }
        
      """
      misc.cgconfig.parse(mount_obj).should.eql {
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ,
          type: 'cpuset'
          path: '/cgroup/cpusetbis'
        ,
          type: 'cpu'
          path: '/cgroup/cpubis'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacctbis'
        ,
          type: 'memory'
          path: '/cgroup/memorybis'
        ,
          type: 'devices'
          path: '/cgroup/devicesbis'
        ]
        groups: {}
      }
    it 'parse group only file', ->
      mount_obj = """
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
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
      """
      misc.cgconfig.parse(mount_obj).should.eql {
          mounts: []
          groups:
            toto:
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
      }
    it 'parse multiple groups file', ->
      mount_obj = """
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
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
        group bibi {
          perm {
            admin {
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
            }
          }
          cpu {
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
      """
      misc.cgconfig.parse(mount_obj).should.eql {
          mounts: []
          groups:
            toto:
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
            bibi:
              perm: 
                admin:
                  uid: 'bibi'
                  gid: 'bibi'
                task:
                  uid: 'bibi'
                  gid: 'bibi'
              cpu: 
                'cpu.rt_period_us': '"1000000"'
                'cpu.rt_runtime_us': '"0"'
                'cpu.cfs_period_us': '"100000"'
      }
    it 'parse mount and groups file', ->
      mount_obj = """
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
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
        group bibi {
          perm {
            admin {
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
            }
          }
          cpu {
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
      """
      misc.cgconfig.parse(mount_obj).should.eql {
          mounts: [
            type: 'cpuset'
            path: '/cgroup/cpuset'
          ,
            type: 'cpu'
            path: '/cgroup/cpu'
          ,
            type: 'cpuacct'
            path: '/cgroup/cpuacct'
          ,
            type: 'memory'
            path: '/cgroup/memory'
          ,
            type: 'devices'
            path: '/cgroup/devices'
          ]
          groups:
            toto:
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
            bibi:
              perm: 
                admin:
                  uid: 'bibi'
                  gid: 'bibi'
                task:
                  uid: 'bibi'
                  gid: 'bibi'
              cpu: 
                'cpu.rt_period_us': '"1000000"'
                'cpu.rt_runtime_us': '"0"'
                'cpu.cfs_period_us': '"100000"'
      }
    it 'parse mount and groups and default file', ->
      mount_obj = """
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
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
        group bibi {
          perm {
            admin {
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
            }
          }
          cpu {
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
        default {
          perm {
            admin {
              uid = root;
              gid = root;
            }
            task {
              uid = root;
              gid = root;
            }
          }
          cpu {
            cpu.rt_period_us="1000000";
            cpu.rt_runtime_us="0";
            cpu.cfs_period_us="100000";
          }
        }
      """
      misc.cgconfig.parse(mount_obj).should.eql {
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ]
        groups:
          toto:
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
          bibi:
            perm: 
              admin:
                uid: 'bibi'
                gid: 'bibi'
              task:
                uid: 'bibi'
                gid: 'bibi'
            cpu: 
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
          '':
            perm: 
              admin:
                uid: 'root'
                gid: 'root'
              task:
                uid: 'root'
                gid: 'root'
            cpu: 
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
        }
    it 'stringify a mount only object', ->
      cgroups = 
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ]
      misc.cgconfig.stringify(cgroups).should.eql """
        mount {
          cpuset = /cgroup/cpuset;
          cpu = /cgroup/cpu;
          cpuacct = /cgroup/cpuacct;
          memory = /cgroup/memory;
          devices = /cgroup/devices;
        }
      """
    it 'stringify a group only object', ->
      cgroups = 
        groups:
          toto:
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
      misc.cgconfig.stringify(cgroups).should.eql """
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
    it 'stringify a mount and group object', ->
      cgroups =
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ]
        groups:
          toto:
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
      misc.cgconfig.stringify(cgroups).should.eql """
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
      """
    it 'stringify a mount and multiple group object', ->
      cgroups =
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ]
        groups:
          toto:
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
          bibi:
            perm: 
              admin:
                uid: 'bibi'
                gid: 'bibi'
              task:
                uid: 'bibi'
                gid: 'bibi'
            cpu: 
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
      misc.cgconfig.stringify(cgroups).should.eql """
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
        group bibi {
          perm {
            admin {
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
            }
          }
          cpu {
            cpu.rt_period_us = "1000000";
            cpu.rt_runtime_us = "0";
            cpu.cfs_period_us = "100000";
          }
        }
      """
    it 'stringify a mount and multiple group and default object', ->
      cgroups =
        mounts: [
          type: 'cpuset'
          path: '/cgroup/cpuset'
        ,
          type: 'cpu'
          path: '/cgroup/cpu'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacct'
        ,
          type: 'memory'
          path: '/cgroup/memory'
        ,
          type: 'devices'
          path: '/cgroup/devices'
        ,
          type: 'cpuset'
          path: '/cgroup/cpusetbis'
        ,
          type: 'cpu'
          path: '/cgroup/cpubis'
        ,
          type: 'cpuacct'
          path: '/cgroup/cpuacctbis'
        ,
          type: 'memory'
          path: '/cgroup/memorybis'
        ,
          type: 'devices'
          path: '/cgroup/devicesbis'
        ]
        groups:
          toto:
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
          bibi:
            perm: 
              admin:
                uid: 'bibi'
                gid: 'bibi'
              task:
                uid: 'bibi'
                gid: 'bibi'
            cpu: 
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
          default:
            perm: 
              admin:
                uid: 'bibi'
                gid: 'bibi'
              task:
                uid: 'bibi'
                gid: 'bibi'
            cpu: 
              'cpu.rt_period_us': '"1000000"'
              'cpu.rt_runtime_us': '"0"'
              'cpu.cfs_period_us': '"100000"'
      misc.cgconfig.stringify(cgroups).should.eql """
        mount {
          cpuset = /cgroup/cpuset;
          cpu = /cgroup/cpu;
          cpuacct = /cgroup/cpuacct;
          memory = /cgroup/memory;
          devices = /cgroup/devices;
          cpuset = /cgroup/cpusetbis;
          cpu = /cgroup/cpubis;
          cpuacct = /cgroup/cpuacctbis;
          memory = /cgroup/memorybis;
          devices = /cgroup/devicesbis;
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
        group bibi {
          perm {
            admin {
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
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
              uid = bibi;
              gid = bibi;
            }
            task {
              uid = bibi;
              gid = bibi;
            }
          }
          cpu {
            cpu.rt_period_us = "1000000";
            cpu.rt_runtime_us = "0";
            cpu.cfs_period_us = "100000";
          }
        }
      """

  describe 'tmpfs', ->
    it 'parse single complete line file', ->
      obj = """
        # screen needs directory in /var/run
        d /var/run/file_1 0775 root nikita 10s -
      """
      expected =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
          age: '10s'
          argu: '-'
      content = misc.tmpfs.parse obj
      content.should.eql expected
    it 'parse uncomplete complete line file', ->
      obj = """
        # screen needs directory in /var/run
        d /var/run/file_1 0775 root nikita
      """
      expected =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
          age: '-'
          argu: '-'
      content = misc.tmpfs.parse obj
      content.should.eql expected
    it 'parse multiple complete line file', ->
      obj = """
        # nikita needs directory in /var/run
        d /var/run/file_1 0775 root nikita 10s -
        # an other comment ^^
        d /var/run/file_2 0775 root nikita 10s -
      """
      expected =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
          age: '10s'
          argu: '-'
        '/var/run/file_2':
          type: 'd'
          mount: '/var/run/file_2'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
          age: '10s'
          argu: '-'
      content = misc.tmpfs.parse obj
      content.should.eql expected
    it 'stringify single complete object file', ->
      obj =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
          age: '10s'
          argu: '-'
      misc.tmpfs.stringify(obj).should.eql """
          d /var/run/file_1 0775 root nikita 10s -
        """
    it 'stringify not defined by omission value file', ->
      obj =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
      misc.tmpfs.stringify(obj).should.eql """
          d /var/run/file_1 0775 root nikita - -
        """
    it 'stringify multiple files', ->
      obj =
        '/var/run/file_1':
          type: 'd'
          mount: '/var/run/file_1'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
        '/var/run/file_2':
          type: 'd'
          mount: '/var/run/file_2'
          perm: '0775'
          uid: 'root'
          gid: 'nikita'
      misc.tmpfs.stringify(obj).should.eql """
          d /var/run/file_1 0775 root nikita - -
          d /var/run/file_2 0775 root nikita - -
        """
