
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: true
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
