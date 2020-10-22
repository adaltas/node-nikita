
path = require 'path'
nikita = require '@nikitajs/core'
require '@nikitajs/lxd/src/register'

nikita
  debug: true
# .lxd.delete
#   container: 'tools-rubygem'
#   force: true
.lxd.cluster
  containers:
    'tools-rubygem':
      image: 'images:centos/7'
      disk:
        nikitadir: source: path.join(__dirname, '../../../../'), path: '/nikita'
.lxd.exec
  container: 'tools-rubygem'
  cmd: """
  NPM_CONFIG_LOGLEVEL=info
  NODE_VERSION=12.13.1
  yum install -y xz \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"
  # Create SSH user
  groupadd -r sshuser && useradd --no-log-init -m -r -g sshuser sshuser
  # Activate SSH connection
  if [ ! -f /home/sshuser/.ssh ]; then
    yum install -y openssh-server openssh-clients \
    && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
    && mkdir /home/sshuser/.ssh \
    && chmod 700 /home/sshuser \
    && cat ~/.ssh/id_rsa.pub > /home/sshuser/.ssh/authorized_keys \
    && chown -R sshuser /home/sshuser/.ssh \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key
  fi
  yum install -y gcc ruby ruby-devel
  """
.lxd.exec
  container: 'tools-rubygem'
  cmd: """
  NIKITA_TEST_MODULE=/nikita/packages/tools/env/rubygems/test.coffee
  cd /nikita/packages/tools
  npm test
  """
