
path = require 'path'
nikita = require '@nikitajs/engine/src'
require '@nikitajs/lxd/src/register'
require '@nikitajs/tools/src/register'

# Note:
# Dec 4th, 2020: upgrading Atom to 1.52.0 or 1.53.0 on centos7 20201203_07:08
# lead to an error while running `apm`
# "Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found"
# issue is open on the moment - https://github.com/atom/atom/issues/21497

nikita
.log.cli pad: host: 20, header: 60
.log.md filename: '/tmp/nikita_tools_apm_lxd_install'
.lxd.cluster
  header: 'Container'
  containers:
    'tools-apm':
      image: 'images:centos/7'
      config:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/apm/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: "#{__dirname}/../../assets/id_rsa.pub"
  prevision: ({config}) ->
    @tools.ssh.keygen
      header: 'SSH key'
      target: "#{__dirname}/../../assets/id_rsa"
      bits: 2048
      key_format: 'PEM'
      comment: 'nikita'
  provision_container: ({config}) ->
    @lxd.exec
      header: 'Node.js'
      container: config.container
      command: """
      command -v node && exit 42
      NODE_VERSION=12.13.1
      yum install -y xz
      curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz
      tar -xJf "/tmp/node.tar.xz" -C /usr/local --strip-components=1
      rm -f "/tmp/node.tar.xz"
      """
      trap: true
      code_skipped: 42
    @lxd.file.push
      header: 'User Private Key'
      container: config.container
      gid: 'nikita'
      uid: 'nikita'
      source: "#{__dirname}/../../assets/id_rsa"
      target: '/home/nikita/.ssh/id_rsa'
    @lxd.exec
      header: 'Root SSH dir'
      container: config.container
      command: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
    @lxd.file.push
      header: 'Root SSH Private Key'
      container: config.container
      gid: 'root'
      uid: 'root'
      source: "#{__dirname}/../../assets/id_rsa"
      target: '/root/.ssh/id_rsa'
    @lxd.exec
      header: 'Install Atom'
      container: config.container
      command: """
      apm -v | grep apm && exit 42
      yum install -y wget
      wget https://github.com/atom/atom/releases/download/v1.51.0/atom.x86_64.rpm
      yum install -y atom.x86_64.rpm
      """
      trap: true
      code_skipped: 42
