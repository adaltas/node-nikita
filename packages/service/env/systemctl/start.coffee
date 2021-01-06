
path = require 'path'
nikita = require '@nikitajs/engine/lib'
require '@nikitajs/lxd/lib/register'
require '@nikitajs/tools/lib/register'

# Note:
# Dec 4th, 2020: upgrading Atom to 1.52.0 or 1.53.0 on centos7 20201203_07:08
# lead to an error while running `apm`
# "Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found"
# issue is open on the moment - https://github.com/atom/atom/issues/21497

nikita
.log.cli pad: host: 20, header: 60
.log.md filename: '/tmp/nikita_service_systemctl'
.lxd.cluster
  metadata: header: 'Container'
  containers:
    'nikita-service-systemctl':
      image: 'images:centos/7'
      properties:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/service/env/systemctl/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
  provision_container: ({config}) ->
    await @lxd.exec
      metadata: header: 'Node.js'
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
    await @lxd.exec
      metadata: header: 'SSH', debug: true
      container: config.container
      command: """
      mkdir -p /root/.ssh && chmod 700 /root/.ssh
      yum install -y openssh-server openssh-clients
      if [ ! -f /root/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
        cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
      fi
      """
      trap: true
