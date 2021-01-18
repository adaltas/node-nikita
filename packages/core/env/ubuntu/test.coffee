
module.exports =
  tags:
    conditions_if_os: false
    system_chmod: false
    system_cgroups: false
    system_discover: false
    system_info: false
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
