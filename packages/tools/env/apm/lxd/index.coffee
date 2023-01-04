
path = require 'path'
runner = require '@nikitajs/lxd-runner'

# Note:
# - Jan 3rd, 2023: rewrite the all thing, run as nikita user
# Error: The module '/home/nikita/.nvm/versions/node/v14.21.2/lib/node_modules/atom-package-manager/node_modules/git-utils/build/Release/git.node'
# was compiled against a different Node.js version using
# NODE_MODULE_VERSION 83. This version of Node.js requires
# NODE_MODULE_VERSION 72. Please try re-compiling or re-installing
# - Dec 4th, 2020: upgrading Atom to 1.52.0 or 1.53.0 on centos7 20201203_07:08
#   lead to an error while running `apm`
#   "Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found"
#   issue is open on the moment - https://github.com/atom/atom/issues/21497

runner
  cwd: '/nikita/packages/tools'
  container: 'nikita-tools-apm'
  logdir: path.resolve __dirname, './logs'
  test_user: 1234
  cluster:
    containers:
      'nikita-tools-apm':
        image: 'images:almalinux/8'
        properties:
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/apm/test.coffee'
          'environment.HOME': '/home/nikita' # Fix, LXD doesnt set HOME with --user
          'raw.idmap': if process.env['NIKITA_LXD_IN_VAGRANT']
          then 'both 1000 0'
          else "both #{process.getuid()} 0"
        disk:
          nikitadir:
            path: '/nikita'
            source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
        ssh: enabled: true
    provision_container: ({config}) ->
      await @lxc.exec
        $header: 'Dependencies'
        container: config.container
        command: '''
        # nvm require the tar commands
        dnf install -y tar
        dnf install -y gcc gcc-c++ kernel-devel python3 make
        '''
        trap: true
      await @lxc.exec
        $header: 'User `nikita`'
        container: config.container
        command: '''
        if ! id -u 1234 ; then
          useradd -m -s /bin/bash -u 1234 nikita
        fi
        '''
        trap: true
      await @lxc.exec
        $header: 'Node.js'
        container: config.container
        command: '''
        if command -v node ; then exit 42; fi
        curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
        . ~/.bashrc
        nvm install 14
        '''
        user: '1234'
        shell: 'bash'
        trap: true
        code: [0, 42]
      await @lxc.exec
        $header: 'SSH keys'
        container: config.container
        command: """
        if [ -f ~/.ssh/id_ed25519 ]; then exit 42; fi
        mkdir -p ~/.ssh && chmod 700 ~/.ssh
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''
        cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys
        """
        trap: true
        user: '1234'
        code: [0, 42]
      await @lxc.exec
        $header: 'Install Atom'
        container: config.container
        command: """
        # apm -v | grep apm && exit 42
        . ~/.bashrc
        npm install -g atom-package-manager
        """
        trap: true
        shell: 'bash'
        user: '1234'
        code: [0, 42]
      # await @lxc.exec
      #   $header: 'Install Atom'
      #   container: config.container
      #   command: """
      #   env
      #   """
      #   shell: 'bash -l'
      #   user: '1234'
      #   code: [0, 42]
.catch (err) ->
  console.error err
