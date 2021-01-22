const nikita = require('nikita');
nikita
// Activate CLI reporting
.log.cli()
// Call any action
.file.properties({
  metadata: {
    // The CLI message
    header: 'Redis configuration',
  },
  target: '/tmp/nikita-tutorial/conf/redis.conf',
  separator: ' ',
  content: {
    'bind': '127.0.0.1',
    'daemonize': 'yes',
    'protected-mode': 'yes',
    'port': 6379
  }
})
