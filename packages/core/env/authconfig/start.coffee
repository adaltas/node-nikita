
nikita = require '../../'
require '../../../lxd/lib/register'
require '../../../tools/lib/register'
cluster = '../cluster'

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
  containers:
    authconfig:
      image: 'images:centos/7'
      config:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/core/env/authconfig/test.coffee'
      disk:
        nikitadir: source: '/nikita', path: '/nikita'
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
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
      key_format: 'PEM'
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
    # @lxd.file.push
    #   header: 'Test configuration'
    #   name: options.container
    #   gid: 'nikita'
    #   uid: 'nikita'
    #   source: './test.coffee'
    #   target: '/nikita/packages/core/test.coffee'
    @lxd.file.push
      header: 'User Private Key'
      name: options.container
      gid: 'nikita'
      uid: 'nikita'
      source: './assets/id_rsa'
      target: '/home/nikita/.ssh/id_rsa'
    @lxd.exec
      header: 'Root SSH dir'
      name: options.container
      cmd: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
    @lxd.file.push
      header: 'Root SSH Private Key'
      name: options.container
      gid: 'root'
      uid: 'root'
      source: './assets/id_rsa'
      target: '/root/.ssh/id_rsa'
    @lxd.exec
      header: 'Package'
      name: options.container
      cmd: 'yum install -y authconfig'
.next (err) ->
  throw err if err
