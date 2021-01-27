// hide-next-line
const nikita = require('nikita');
nikita
.log.cli()
// Start Redis
.execute({
  metadata: {
    header: 'Startup',
  },
  cwd: '/tmp/nikita-tutorial',
  code_skipped: 3,
  command: `
  # Exit code 3 if ping is successful
  redis-stable/src/redis-cli ping && exit 3
  # Otherwise start the server
  nohup redis-stable/src/redis-server conf/redis.conf &
  `
})
