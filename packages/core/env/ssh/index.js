
import path from 'node:path';
import dedent from 'dedent';
import runner from '@nikitajs/incus-runner';
const __dirname = new URL( '.', import.meta.url).pathname

runner({
  cwd: '/nikita/packages/core',
  container: 'nikita-core-ssh',
  logdir: path.resolve(__dirname, './logs'),
  test_user: 1234,
  cluster: {
    containers: {
      'nikita-core-ssh': {
        image: 'images:almalinux/8',
        properties: {
          'environment.NIKITA_TEST_MODULE': '/nikita/packages/core/env/ssh/test.coffee',
          'environment.HOME': '/home/source', // Fix, Incus doesnt set HOME with --user
          'raw.idmap': process.env['NIKITA_INCUS_IN_VAGRANT'] ? 'both 1000 1234' : `both ${process.getuid()} 1234`
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
        $header: 'Dependencies',
        container: config.container,
        command: dedent`
          # nvm require the tar commands
          yum install -y tar
        `
      });
      await this.incus.exec({
        $header: 'User `source`',
        container: config.container,
        command: dedent`
          if ! id -u 1234 ; then
            useradd -m -s /bin/bash -u 1234 source
          fi
          mkdir -p /home/source/.ssh && chmod 700 /home/source/.ssh
          if [ ! -f /home/source/.ssh/id_rsa ]; then
            ssh-keygen -t rsa -f /home/source/.ssh/id_rsa -N ''
          fi
          chown -R source /home/source/
        `,
        trap: true
      });
      await this.incus.exec({
        $header: 'Node.js',
        container: config.container,
        command: dedent`
          if command -v node ; then exit 42; fi
          curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
          . ~/.bashrc
          nvm install 22
        `,
        user: 1234,
        shell: 'bash',
        trap: true,
        code: [0, 42]
      });
      await this.incus.exec({
        $header: 'User `target`',
        container: config.container,
        command: dedent`
          if ! id -u 1235; then
            useradd -m -s /bin/bash -u 1235 target
          fi
          mkdir -p /home/target/.ssh && chmod 700 /home/target/.ssh
          pubkey=\`cat /home/source/.ssh/id_rsa.pub\`
          if ! cat /home/target/.ssh/authorized_keys | grep $pubkey; then
            echo $pubkey > /home/target/.ssh/authorized_keys
          fi
          chown -R target /home/target/
        `,
        trap: true
      });
    }
  }
});
