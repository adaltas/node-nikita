const nikita = require('nikita');
nikita
.log.cli()
// Open the SSH Connection
.ssh.open({
  metadata: {
    header: 'SSH open',
  },
  host: '127.0.0.1',
  port: 22,
  private_key_path: '~/.ssh/id_rsa',
  username: process.env.USER
})
// Call one or multiple actions
.call(() => {
  console.info('Business as usual')
})
// Close the SSH Connection
.ssh.close({
  metadata: {
    header: 'SSH close',
  },
})
