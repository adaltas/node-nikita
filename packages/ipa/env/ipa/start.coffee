
path = require 'path'
nikita = require '@nikitajs/core/lib'
require '@nikitajs/lxd/lib/register'
require '@nikitajs/tools/lib/register'

# Note:
# Jan 20th, 2020: upgrading ubuntu to 19.10 on the host vm
# lead to an error while installing freeipa
# complaining that it cannot write into /tmp
# solution involve to run on the host machine
# Temporary: `echo '0' > /proc/sys/fs/protected_regular && sysctl -p`
# Permanently: `echo 'fs.protected_regular = 0' >> /etc/sysctl.conf && sysctl -p`

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
.lxc.cluster
  $header: 'Container'
  # FreeIPA do a reverse lookup on initialisation
  # Using the default bridge yields to the error
  # `The host name freeipa.nikita does not match the value freeipa.lxd obtained by reverse lookup on IP address fd42:f662:97ea:ba7f:216:3eff:fe1d:96f2%215`
  networks:
    nktipapub:
      'ipv4.address': '10.10.11.1/24'
      'ipv4.nat': true
      'ipv6.address': 'none'
      'dns.domain': 'nikita.local'
  containers:
    'nikita-ipa':
      image: 'images:centos/7'
      properties:
        'environment.NIKITA_TEST_MODULE': '/nikita/packages/ipa/env/ipa/test.coffee'
        'raw.idmap': if process.env['NIKITA_LXD_IN_VAGRANT']
        then 'both 1000 0'
        else "both #{process.getuid()} 0"
      disk:
        nikitadir:
          path: '/nikita'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      nic:
        eth0:
          name: 'eth0', nictype: 'bridged', parent: 'nktipapub'
          'ipv4.address': '10.10.11.2'
      proxy:
        ssh: listen: 'tcp:0.0.0.0:2200', connect: 'tcp:127.0.0.1:22'
        ipa_ui_http: listen: 'tcp:0.0.0.0:2080', connect: 'tcp:127.0.0.1:80'
        ipa_ui_https: listen: 'tcp:0.0.0.0:2443', connect: 'tcp:127.0.0.1:443'
      ssh: enabled: true
  provision_container: ({config}) ->
    await @lxc.exec
      $header: 'Node.js'
      container: config.container
      command: '''
      bash -l -c "command -v node" && exit 42
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
      . ~/.bashrc
      nvm install node
      '''
      code_skipped: 42
      trap: true
    await @lxc.exec
      $header: 'SSH keys'
      container: config.container
      command: """
      grep "`cat /root/.ssh/id_rsa.pub`" /root/.ssh/authorized_keys && exit 42
      mkdir -p /root/.ssh && chmod 700 /root/.ssh
      if [ ! -f /root/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
        cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
      fi
      """
      code_skipped: 42
      trap: true
    await @lxc.exec
      $header: 'Install FreeIPA'
      container: config.container
      code_skipped: 42
      # Other possibilities to check ipa status:
      # echo > /dev/tcp/localhost/443
      # echo admin_pw | kinit admin
      command: """
      [ -f /etc/ipa/default.conf ] && exit 42
      yum install -y freeipa-server ipa-server-dns
      hostnamectl set-hostname ipa.nikita.local --static
      #{[
        'ipa-server-install', '-U'
        #  Basic options
        "-a admin_pw"
        "-p manager_pw"
        # The container is named `nikita-ipa` and it is attached to a network
        # with the `nikita.local` DNS domain. Thus, the default FQDN is
        # `nikita-ipa.nikita.local` and you can do a reverse DNS lookup with
        # `dig -x`.
        "--hostname ipa.nikita.local"
        "--domain nikita.local"
        # We can set a different FQDN like `ipa.nikita.local` with `hostnamectl
        # set-hostname {fqdn} --static`. However, FreeIPA will complain when it
        # starts because the reverse DNS lookup check fail to match the FQDN. A
        # possible solution is to have FreeIPA managing the DNS with
        # `--setup-dns`.
        "--setup-dns --auto-reverse --auto-forwarders"
        # Kerberos REALM
        "-r NIKITA.LOCAL"
      ].join ' '}
      """
      # ipa-server-install --uninstall
      # ipa-server-install -U -a admin_pw -p manager_pw --hostname ipa.nikita.local --domain nikita.local --auto-reverse --setup-dns --auto-forwarders -r NIKITA.LOCAL
