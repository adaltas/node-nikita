
module.exports =
  tags:
    db: true
  db:
    postgresql:
      engine: 'postgresql'
      host: 'postgres'
      port: 5432
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  ssh:
    host: 'localhost'
    username: 'root'
