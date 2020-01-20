
path = require 'path'
os = require 'os'
nikita = require '@nikitajs/core'
require '@nikitajs/lxd/lib/register'
require '@nikitajs/tools/lib/register'
require '@nikitajs/lxd/lib/register'

# Note:
# Jan 20th, 2020: upgrading ubuntu to 19.10
# lead to an error while installing freeipa
# complaining that it cannot write into /tmp
# solution involve `echo '0' > /proc/sys/fs/protected_regular && sysctl -p`

# console.log path.join os.tmpdir(), 'nikita_ipa_lxd_install'
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
  # debug: true # params.debug
  networks:
    lxdbr0public:
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
        nikitadir: source: '/nikita', path: '/nikita'
      nic:
        eth0:
          config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
        ipa_ui_http: listen: 'tcp:0.0.0.0:2080', connect: 'tcp:127.0.0.1:80'
        ipa_ui_https: listen: 'tcp:0.0.0.0:2443', connect: 'tcp:127.0.0.1:443'
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
      NODE_VERSION=10.12.0
      yum install -y xz
      curl -SL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz
      tar -xJf "/tmp/node.tar.xz" -C /usr/local --strip-components=1
      rm -f "/tmp/node.tar.xz"
      """
      trap: true
      code_skipped: 42
    @lxd.file.push
      header: 'User Private Key'
      container: options.container
      gid: 'nikita'
      uid: 'nikita'
      source: './assets/id_rsa'
      target: '/home/nikita/.ssh/id_rsa'
    @lxd.exec
      header: 'Root SSH dir'
      container: options.container
      cmd: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
    @lxd.file.push
      header: 'Root SSH Private Key'
      container: options.container
      gid: 'root'
      uid: 'root'
      source: './assets/id_rsa'
      target: '/root/.ssh/id_rsa'
    @lxd.exec
      header: 'Install FreeIPA'
      container: options.container
      code_skipped: 42
      # Other possibilities to check ipa status:
      # echo > /dev/tcp/localhost/443
      # echo admin_pw | kinit admin
      cmd: """
      [ -f /etc/ipa/default.conf ] && exit 42
      yum install -y freeipa-server
      hostnamectl set-hostname freeipa.nikita.local --static
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
.next (err) ->
  throw err if err
