const nikita = require('nikita');
nikita
// Activate Markdown reporting
.log.md({
  basedir: '/tmp/nikita-tutorial/log'
})
// Call any action
.file.properties({
  metadata: {
    // The Markdown header
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
