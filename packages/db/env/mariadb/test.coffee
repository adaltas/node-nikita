
export default
  tags:
    api: false
    db: true
  db:
    mariadb:
      admin_password: 'rootme'
      admin_username: 'root'
      engine: 'mariadb'
      host: 'mariadb'
      port: 3306
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_ed25519'
  ]
