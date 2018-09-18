
module.exports =
  tags:
    db: true
  db:
    mariadb:
      engine: 'mariadb'
      host: 'mariadb'
      port: 3306
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  ssh:
    host: 'localhost'
    username: 'root'
