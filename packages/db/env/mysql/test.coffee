
export default
  tags:
    db: true
  db:
    mysql:
      admin_password: 'rootme'
      admin_username: 'root'
      engine: 'mysql'
      host: 'mysql'
      port: 3306
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_ed25519'
  ]
