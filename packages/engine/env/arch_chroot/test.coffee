
module.exports =
  tags:
    conditions_if_os: true
    system_execute_arc_chroot: true
  conditions_if_os:
    arch: '64'
    name: 'arch'
    linux_version: '4.19'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
