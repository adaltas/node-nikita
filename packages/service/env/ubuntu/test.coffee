
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false
  conditions_is_os:
    arch: '64'
    name: 'ubuntu'
    version: '14.04'
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
