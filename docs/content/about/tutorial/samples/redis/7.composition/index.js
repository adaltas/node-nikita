const nikita = require('nikita');
const cwd = '/tmp/nikita-tutorial';
nikita
.log.cli()
.log.md({
  basedir: `${cwd}/log`
})
.ssh.open({
  metadata: {
    header: 'SSH Open'
  },
  host: '127.0.0.1',
  port: 22,
  username: process.env.USER,
  private_key_path: '~/.ssh/id_rsa'
})
.call({
  metadata: {
    header: 'Redis installation',
  },
  handler: function(){
    this.file.download({
      metadata: {
        header: 'Downloading',
      },
      source: 'http://download.redis.io/redis-stable.tar.gz',
      target: `${cwd}/cache/redis-stable.tar.gz`
    })
    this.execute({
      metadata: {
        header: 'Compilation',
      },
      unless_exists: `${cwd}/redis-stable/src/redis-server`,
      cwd: cwd,
      command: `
      tar xzf cache/redis-stable.tar.gz
      cd redis-stable
      make
      `
    })
    this.file.properties({
      metadata: {
        header: 'Configuration',
      },
      target: `${cwd}/conf/redis.conf`,
      separator: ' ',
      content: {
        'bind': '127.0.0.1',
        'daemonize': 'yes',
        'protected-mode': 'yes',
        'port': 6379
      }
    })
    this.execute({
      metadata: {
        header: 'Startup',
      },
      cwd: cwd,
      code_skipped: 3,
      command: `
      redis-stable/src/redis-cli ping && exit 3
      nohup redis-stable/src/redis-server conf/redis.conf &
      `
    })
  }
})
.execute({
  metadata: {
    header: 'Redis Check',
    relax: true,
    shy: true,
  },
  cwd: cwd,
  command: 'redis-stable/src/redis-cli -h 127.0.0.1 -p 6379 ping | grep PONG'
})
.ssh.close({
  metadata: {
    header: 'SSH Close'
  },
})
