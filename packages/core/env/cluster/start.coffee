
nikita = require '../../'
require '../../../lxd/lib/register'
require '../../../tools/lib/register'
cluster = '.'

nikita
.log.cli pad: host: 20, header: 60
.call cluster,
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
        ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
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
      ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
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
      ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
    ssh: enabled: true
    user:
      nikita: sudo: true, authorized_keys: './assets/id_rsa.pub'
  prevision: ({options}) ->
    @tools.ssh.keygen
      header: 'SSH key'
      target: './assets/id_rsa'
      bits: 2048
      comment: 'nikita'
  provision_container: ({options}) ->
    @lxd.exec
      header: 'Node.js'
      name: options.container
      cmd: """
      command -v node && exit 42
      NODE_VERSION=10.12.0
      yum install -y xz
      curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz
      tar -xJf "/tmp/node.tar.xz" -C /usr/local --strip-components=1
      rm -f "/tmp/node.tar.xz"
      """
      trap: true
      code_skipped: 42
    @lxd.file.push
      debug: true
      header: 'Test configuration'
      name: options.container
      gid: 'nikita'
      uid: 'nikita'
      source: './test.coffee'
      target: "/nikita/packages/core/test.coffee"
.next (err) ->
  throw err if err
