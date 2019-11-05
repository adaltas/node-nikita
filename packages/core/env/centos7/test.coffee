
module.exports =
  tags:
    conditions_if_os: true
    service_install: false
    service_startup: false
    service_systemctl: false
    system_chmod: true
    system_discover: true
    system_info: true
    system_limits: true
    system_tmpfs: true
    system_user: true
  conditions_is_os:
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
