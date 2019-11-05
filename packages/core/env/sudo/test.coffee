
module.exports =
  tags:
    sudo: true
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
