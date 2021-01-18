
module.exports =
  tags:
    conditions_if_os: true
    system_chmod: true
    system_cgroups: true
    system_discover: true
    system_info: true
  conditions_is_os:
    arch: '64'
    name: 'centos'
    version: '6.8'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
