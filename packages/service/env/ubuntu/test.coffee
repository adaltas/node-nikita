
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
