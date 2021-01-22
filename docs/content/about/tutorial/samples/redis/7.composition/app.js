const nikita = require('nikita');
// Dependencies
const install = require('./lib/install');
const check = require('./lib/check');
// Configuration
config = {
  ssh: {
    host: '127.0.0.1',
    port: 22,
    private_key_path: '~/.ssh/id_rsa',
    username: process.env.USER
  },
  redis: {
    cwd: '/tmp/nikita-tutorial',
    config: {}
  }
}
// Run the application
nikita
.log.cli()
.log.md({basedir: '/tmp/nikita-tutorial/log'})
.ssh.open({metadata: {header: 'SSH Open'}}, config.ssh)
.call({metadata: {header: 'Redis Install'}}, config.redis, install)
.call({metadata: {header: 'Redis Check'}}, config.redis, check)
.ssh.close({metadata: {header: 'SSH Close'}})
