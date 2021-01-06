
path = require 'path'
nikita = require '@nikitajs/engine/lib'
require '@nikitajs/lxd/lib/register'
require '@nikitajs/tools/lib/register'

nikita
.log.cli pad: host: 20, header: 60
.log.md filename: '/tmp/nikita_tools_rubygems_lxd_install'
.lxd.cluster
  metadata: header: 'Container'
  containers:
    'tools-rubygems':
      image: 'images:centos/7'
      properties:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/rubygems.lxd/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: "#{__dirname}/../../assets/id_rsa.pub"
  prevision: ->
    await @tools.ssh.keygen
      metadata: header: 'SSH key'
      target: "#{__dirname}/../../assets/id_rsa"
      bits: 2048
      key_format: 'PEM'
      comment: 'nikita'
  provision_container: ({config}) ->
    await @lxd.exec
      metadata: header: 'Node.js'
      container: config.container
      command: """
      command -v node && exit 42
      NPM_CONFIG_LOGLEVEL=info
      NODE_VERSION=12.13.1
      yum install -y xz
      curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz
      tar -xJf "/tmp/node.tar.xz" -C /usr/local --strip-components=1
      rm -f "/tmp/node.tar.xz"
      """
      trap: true
      code_skipped: 42
    await @lxd.exec
      metadata: header: 'Ruby'
      container: config.container
      command: """
      yum install -y gcc ruby ruby-devel
      """
      trap: true
      code_skipped: 42
    await @lxd.file.push
      metadata: header: 'User Private Key'
      container: config.container
      gid: 'nikita'
      uid: 'nikita'
      source: "#{__dirname}/../../assets/id_rsa"
      target: '/home/nikita/.ssh/id_rsa'
    await @lxd.exec
      metadata: header: 'Root SSH dir'
      container: config.container
      command: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
    await @lxd.file.push
      metadata: header: 'Root SSH Private Key'
      container: config.container
      gid: 'root'
      uid: 'root'
      source: "#{__dirname}/../../assets/id_rsa"
      target: '/root/.ssh/id_rsa'
