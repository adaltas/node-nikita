// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita.file.download({
    source: 'http://download.redis.io/redis-stable.tar.gz',
    target: '/tmp/nikita-tutorial/cache/redis-stable.tar.gz'
  })
  console.info('Redis downloaded:', status ? '✔' : '-')
})()
