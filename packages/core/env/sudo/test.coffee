
module.exports =
  tags:
    sudo: true
  ssh:
    host: 'localhost'
    username: 'nikita'
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
