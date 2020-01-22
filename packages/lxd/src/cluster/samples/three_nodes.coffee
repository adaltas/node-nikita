
nikita = require '@nikitajs/core'
require '@nikitajs/tools/lib/register'
require '../../register'

###

Notes:

SSH private and public keys will be generated in an "assets" directory inside
the current working directory.

###

nikita
.log.cli pad: host: 20, header: 60
.lxd.cluster
  header: 'Container'
  network:
    lxdbr0public:
      'ipv4.address': '172.16.0.1/24'
      'ipv4.nat': true
      'ipv6.address': 'none'
      'dns.domain': 'nikita'
    lxdbr1private:
      'ipv4.address': '10.10.10.1/24'
      'ipv4.nat': false
      'ipv6.address': 'none'
      'dns.domain': 'nikita'
  containers:
    n1:
      image: 'images:centos/7'
      disk:
        nikitadir: source: '/nikita', path: '/nikita'
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
        eth1:
          config: name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
          ip: '10.10.10.11', netmask: '255.255.255.0'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2201', connect: 'tcp:127.0.0.1:22'
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: './assets/id_rsa.pub'
    n2:
      image: 'images:centos/7'
      disk:
        nikitadir: source: '/nikita', path: '/nikita'
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
        eth1:
          config: name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
          ip: '10.10.10.12', netmask: '255.255.255.0'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2202', connect: 'tcp:127.0.0.1:22'
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: './assets/id_rsa.pub'
    n3:
      image: 'images:centos/7'
      disk:
        nikitadir: source: '/nikita', path: '/nikita'
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
        eth1:
          config: name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
          ip: '10.10.10.13', netmask: '255.255.255.0'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2203', connect: 'tcp:127.0.0.1:22'
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: './assets/id_rsa.pub'
  prevision: ({options}) ->
    @tools.ssh.keygen
      header: 'SSH key'
      target: './assets/id_rsa'
      bits: 2048
      key_format: 'PEM'
      comment: 'nikita'
  provision_container: ({options}) ->
    @lxd.exec
      header: 'Node.js'
      container: options.container
      cmd: """
      command -v node && exit 42
      curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
      bash n lts
      """
      trap: true
      code_skipped: 42
    # @lxd.file.push
    #   debug: true
    #   header: 'Test configuration'
    #   container: options.container
    #   gid: 'nikita'
    #   uid: 'nikita'
    #   source: './test.coffee'
    #   target: '/nikita/packages/core/test.coffee'
.next (err) ->
  throw err if err
