// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita.file.properties({
    target: '/tmp/nikita-tutorial/conf/redis.conf',
    separator: ' ',
    content: {
      'bind': '127.0.0.1',
      'daemonize': 'yes',
      'protected-mode': 'yes',
      'port': 6379
    }
  })
  console.info('Redis configuration set:', status ? '✔' : '-')
})()
