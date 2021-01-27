// hide-next-line
const nikita = require('nikita');
(async () => {
  var {status} = await nikita.execute({
    unless_exists: '/tmp/nikita-tutorial/redis-stable/src/redis-server',
    command: `
    tar xzf /tmp/nikita-tutorial/cache/redis-stable.tar.gz -C /tmp/nikita-tutorial
    cd /tmp/nikita-tutorial/redis-stable
    make
    `
  })
  console.info('Redis compiled:', status ? '✔' : '-')
})()
