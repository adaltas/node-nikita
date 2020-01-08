
module.exports =
  tags:
    db: true
  db:
    postgresql:
      admin_username: 'root'
      admin_password: 'rootme'
      engine: 'postgresql'
      host: 'postgres'
      port: 5432
      admin_db: 'root'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
