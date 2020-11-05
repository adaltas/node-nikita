
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: true
  conditions_if_os:
    arch: '64'
    name: 'centos'
    version: '6.8'
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
