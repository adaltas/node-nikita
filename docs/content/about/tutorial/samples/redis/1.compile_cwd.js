const nikita = require('nikita');
(async () => {
  var {status} = await nikita.execute({
    unless_exists: '/tmp/nikita-tutorial/redis-stable/src/redis-server',
    cwd: '/tmp/nikita-tutorial',  // Define current working directory
    command: `
    tar xzf cache/redis-stable.tar.gz
    cd redis-stable
    make
    `
  })
  console.info('Redis compiled:', status ? '✔' : '-')
})()
