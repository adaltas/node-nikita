
path = require 'path'
nikita = require '@nikitajs/engine/src'
require '@nikitajs/lxd/src/register'
require '@nikitajs/tools/src/register'

# Note:
# Jan 20th, 2020: upgrading ubuntu to 19.10
# lead to an error while installing freeipa
# complaining that it cannot write into /tmp
# solution involve `echo '0' > /proc/sys/fs/protected_regular && sysctl -p`
# Dec 4th, 2020: same for centos/7 20201203_07:08
# solution involve `chmod -R 777 /tmp`

# console.info path.join os.tmpdir(), 'nikita_ipa_lxd_install'
# parameters({
#   name: 'nikita_lxd'
#   description: 'Nikita LXD tests'
#   commands:
#     enter:
#       description: 'Run all the tests'
#       options:
#         debug:
#           description: 'Print debug information to the console'
#           shortcut: 'd'
#     exec:
#       description: 'Run all or a subset of the tests'
#       options:
#         debug:
#           description: 'Print debug information to the console'
#           shortcut: 'd'
# })

nikita
.log.cli pad: host: 20, header: 60
.log.md filename: '/tmp/nikita_ipa_lxd_install'
.lxd.cluster
  header: 'Container'
  networks:
    lxdbr0freeipa:
      'ipv4.address': '172.16.0.1/24'
      'ipv4.nat': true
      'ipv6.address': 'none'
      'dns.domain': 'nikita.local'
  containers:
    freeipa:
      image: 'images:centos/7'
      config:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/ipa/env/ipa/test.coffee'
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0freeipa'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
        ipa_ui_http: listen: 'tcp:0.0.0.0:2080', connect: 'tcp:127.0.0.1:80'
        ipa_ui_https: listen: 'tcp:0.0.0.0:2443', connect: 'tcp:127.0.0.1:443'
      ssh: enabled: true
      user:
        nikita: sudo: true, authorized_keys: "./assets/id_rsa.pub"
  prevision: ({config}) ->
    @tools.ssh.keygen
      header: 'SSH key'
      target: "./assets/id_rsa"
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
      source: "./assets/id_rsa"
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
      source: "./assets/id_rsa"
      target: '/root/.ssh/id_rsa'
    @lxd.exec
      header: 'Install FreeIPA'
      container: config.container
      code_skipped: 42
      # Other possibilities to check ipa status:
      # echo > /dev/tcp/localhost/443
      # echo admin_pw | kinit admin
      command: """
      [ -f /etc/ipa/default.conf ] && exit 42
      yum install -y freeipa-server
      hostnamectl set-hostname freeipa.nikita.local --static
      chmod -R 777 /tmp
      #{[
        'ipa-server-install', '-U'
        #  Basic options
        "-a admin_pw"
        "-p manager_pw"
        "--hostname freeipa.nikita.local"
        "--domain nikita.local"
        # Kerberos REALM
        "-r NIKITA.LOCAL"
      ].join ' '}
      """
