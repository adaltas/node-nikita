
module.exports =
  tags:
    conditions_if_os: true
    service_install: true
    service_startup: true
    service_systemctl: true
    system_chmod: true
    system_cgroups: true
    system_discover: true
    system_info: true
    system_limits: true
    system_user: true
  conditions_is_os:
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
