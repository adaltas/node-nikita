
nikita = require '../../'
require '../../../lxd/lib/register'

nikita
.log.cli pad: host: 20, header: 60
.system.mkdir
  target: "#{process.cwd()}/assets"
.system.execute
  unless_exists: "#{process.cwd()}/assets/id_rsa"
  cmd: "ssh-keygen -t rsa -b 2048 -C nikita -f #{process.cwd()}/assets/id_rsa"
.lxd.network
  name: 'lxdbr0pub'
  config:
    'ipv4.address': '172.16.0.1/24'
    'ipv4.nat': 'true'
    'ipv6.address': 'none'
    'dns.domain': 'nikita'
.lxd.init
  image: 'images:centos/7'
  name: 'centos7'
.lxd.config.device.add
  header: 'Device eth0'
  name: 'centos7'
  device: 'eth0'
  type: 'nic'
  config:
    name: 'eth0'
    nictype: 'bridged'
    parent: 'lxdbr0pub'
.lxd.config.device.add
  header: 'Device eth0'
  name: 'centos7'
  device: 'ssh'
  type: 'proxy'
  config:
    listen: 'tcp:0.0.0.0:2200'
    connect: 'tcp:127.0.0.1:22'
.lxd.config.device.add
  name: 'centos7'
  device: 'nikitadir'
  type: 'disk'
  config:
    source: '/nikita'
    path: '/nikita'
.lxd.start
  name: 'centos7'
.lxd.exec
  header: 'Sudo'
  name: 'centos7'
  cmd: """
  yum update -y
  yum install -y openssl
  command -p openssl
  """
  retry: 3
  trap: true
.lxd.exec
  header: 'User nikita'
  name: 'centos7'
  cmd: """
  id nikita && exit 42
  useradd --create-home --system nikita
  mkdir -p /home/nikita/.ssh
  chown nikita.nikita /home/nikita/.ssh
  chmod 700 /home/nikita/.ssh
  """
  trap: true
  code_skipped: 42
.lxd.exec
  header: 'Sudo'
  name: 'centos7'
  cmd: """
  yum install -y sudo
  command -p sudo
  cat /etc/sudoers | grep "nikita" && exit 42
  echo "nikita ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  """
  trap: true
  code_skipped: 42
.lxd.file.push
  header: 'Authorize nikita'
  name: 'centos7'
  gid: 'nikita'
  uid: 'nikita'
  mode: 600
  source: "#{process.cwd()}/assets/id_rsa.pub"
  target: '/home/nikita/.ssh/authorized_keys'
.lxd.exec
  header: 'SSH'
  name: 'centos7'
  cmd: """
  systemctl status sshd
  yum install -y openssh-server
  systemctl start sshd
  systemctl enable sshd
  """
  trap: true
  code_skipped: 4
.lxd.exec
  header: 'Node.js'
  name: 'centos7'
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
