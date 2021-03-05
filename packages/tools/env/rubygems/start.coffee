
path = require 'path'
nikita = require '@nikitajs/core/lib'
require '@nikitajs/lxd/lib/register'

nikita
.log.cli pad: host: 20, header: 60
# .log.md filename: '/tmp/nikita_system_authconfig'
.lxd.cluster
  $header: 'Container'
  containers:
    'nikita-tools-rubygems':
      image: 'images:centos/7'
      properties:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/rubygems/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
  provision_container: ({config}) ->
    await @lxd.exec
      $header: 'Node.js'
      container: config.container
      command: '''
      command -v node && exit 42
      NPM_CONFIG_LOGLEVEL=info
      NODE_VERSION=12.13.1
      yum install -y xz
      curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz
      tar -xJf "/tmp/node.tar.xz" -C /usr/local --strip-components=1
      rm -f "/tmp/node.tar.xz"
      '''
      trap: true
      code_skipped: 42
    await @lxd.exec
      $header: 'SSH keys'
      container: config.container
      command: """
      mkdir -p /root/.ssh && chmod 700 /root/.ssh
      if [ ! -f /root/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
        cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
      fi
      """
      trap: true
    await @lxd.exec
      $header: 'Ruby'
      container: config.container
      command: """
      yum install -y gcc ruby ruby-devel
      """
      trap: true
      code_skipped: 42
