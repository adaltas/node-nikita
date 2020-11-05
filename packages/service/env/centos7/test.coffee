
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false # cant be activated because systemctl not compatible with Docker
  conditions_if_os:
    arch: '64'
    name: 'centos'
    version: '7.5'
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
