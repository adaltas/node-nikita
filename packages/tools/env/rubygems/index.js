
import path from 'node:path';
import dedent from 'dedent';
import runner from '@nikitajs/incus-runner';
const __dirname = new URL( '.', import.meta.url).pathname

runner({
  cwd: '/nikita/packages/tools',
  container: 'nikita-tools-rubygems',
  logdir: path.resolve(__dirname, './logs'),
  cluster: {
    containers: {
      'nikita-tools-rubygems': {
        image: 'images:almalinux/8',
        properties: {
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/tools/env/rubygems/test.coffee',
          'raw.idmap': process.env['NIKITA_INCUS_IN_VAGRANT'] ? 'both 1000 0' : `both ${process.getuid()} 0`
        },
        disk: {
          nikitadir: {
            path: '/nikita',
            source: process.env['NIKITA_HOME'] || path.join(__dirname, '../../../../')
          }
        },
        ssh: {
          enabled: true
        }
      }
    },
    provision_container: async function({config}) {
      await this.incus.exec({
        $header: 'Node.js',
        container: config.container,
        command: dedent`
          yum install -y tar
          if command -v node ; then exit 42; fi
          curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
          . ~/.bashrc
          nvm install 16
        `,
        trap: true,
        code: [0, 42]
      });
      await this.incus.exec({
        $header: 'SSH keys',
        container: config.container,
        command: dedent`
          mkdir -p /root/.ssh && chmod 700 /root/.ssh
          if [ ! -f /root/.ssh/id_rsa ]; then
            ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
            cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
          fi
        `,
        trap: true
      });
      await this.incus.exec({
        $header: 'Ruby',
        container: config.container,
        command: `yum install -y gcc ruby ruby-devel`,
        trap: true,
        code: [0, 42]
      });
    }
  }
});
