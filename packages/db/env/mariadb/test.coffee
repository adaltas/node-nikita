
module.exports =
  tags:
    db: true
  db:
    mariadb:
      admin_username: 'root'
      admin_password: 'rootme'
      engine: 'mariadb'
      host: 'mariadb'
      port: 3306
      admin_db: 'root'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
