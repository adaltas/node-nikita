
module.exports =
  tags:
    conditions_if_os: true
    system_chmod: true
    system_discover: true
    system_info: true
    system_tmpfs: true
  conditions_is_os:
    arch: '64'
    name: 'centos'
    version: '7.5'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
