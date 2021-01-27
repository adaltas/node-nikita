// hide-next-line
const nikita = require('nikita');
nikita
.log.cli()
.call({
  metadata: {
    header: 'Redis Check',
  },
  handler: function() {
    this.execute({
      metadata: {
        header: "Check",
        relax: true,
        shy: true
      },
      cwd: '/tmp/nikita-tutorial',
      command: 'redis-stable/src/redis-cli -h 127.0.0.1 -p 6379 ping | grep PONG'
    })
  }
})
