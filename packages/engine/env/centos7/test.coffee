
module.exports =
  tags:
    api: true
    conditions_if_os: true
    posix: true
  conditions_if_os:
    arch: '64'
    name: 'centos'
    version: '7.8'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
