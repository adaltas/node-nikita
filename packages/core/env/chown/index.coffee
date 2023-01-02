
path = require 'path'
runner = require '@nikitajs/lxd-runner'

runner
  cwd: '/nikita/packages/core'
  container: 'nikita-core-chown'
  logdir: path.resolve __dirname, './logs'
  cluster:
    containers:
      'nikita-core-chown':
        image: 'images:almalinux/8'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/core/env/chown/test.coffee'
          'raw.idmap': if parseInt(process.env['NIKITA_LXD_IN_VAGRANT'])
          then 'both 1000 0'
          else "uid #{process.getuid()} 0\ngid #{process.getgid()} 0"
        disk:
          nikitadir:
            path: '/nikita'
            source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
        ssh: enabled: true
    provision_container: ({config}) ->
      await @lxc.exec
        $header: 'Node.js'
        container: config.container
        command: '''
        if command -v node ; then exit 42; fi
        yum install -y tar
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
        . ~/.bashrc
        nvm install 16
        '''
        trap: true
        code: [0, 42]
      await @lxc.exec
        $header: 'SSH keys'
        container: config.container
        command: """
        mkdir -p /root/.ssh && chmod 700 /root/.ssh
        if [ ! -f /root/.ssh/id_ed25519 ]; then
          ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ''
          cat /root/.ssh/id_ed25519.pub > /root/.ssh/authorized_keys
        fi
        """
        trap: true
.catch (err) ->
  console.error err
