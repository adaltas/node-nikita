
module.exports =
  tags:
    db: true
  db:
    mysql:
      engine: 'mysql'
      host: 'mysql'
      port: 3306
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
