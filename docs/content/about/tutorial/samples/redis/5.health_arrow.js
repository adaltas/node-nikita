const nikita = require('nikita');
(async () => {
  var {status} = await nikita(
    async ({context}) => {
      var {status, error} = await context.execute(
        {
          metadata: {
            header: "redis",
            shy: true,
            relax: true
          },
          cwd: '/tmp/nikita-tutorial',
          command: 'redis-stable/src/redis-cli -h 127.0.0.1 -p 6379 ping | grep PONG'
        }
      )
      console.info("Redis check:", error ? 'x' : status ? '✔' : '-')
  })
  console.info("Global status changed:", status ? '✔' : '-')
})()
