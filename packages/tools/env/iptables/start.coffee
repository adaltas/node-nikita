
path = require 'path'
nikita = require '@nikitajs/engine/src'
require '@nikitajs/lxd/src/register'
require '@nikitajs/tools/src/register'

nikita
.log.cli pad: host: 20, header: 60
.log.md filename: '/tmp/nikita_tools_npm_lxd_install'
.lxd.cluster
  header: 'Container'
  containers:
    'tools-iptables':
      image: 'images:centos/7'
      config:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/npm/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: "#{__dirname}/../../assets/id_rsa.pub"
  prevision: ->
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
      cmd: """
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
      cmd: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
    @lxd.file.push
      header: 'Root SSH Private Key'
      container: config.container
      gid: 'root'
      uid: 'root'
      source: "#{__dirname}/../../assets/id_rsa"
      target: '/root/.ssh/id_rsa'
