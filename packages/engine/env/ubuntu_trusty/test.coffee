
module.exports =
  tags:
    api: true
    conditions_if_os: true
    posix: true
  conditions_if_os:
    arch: '64'
    name: 'ubuntu'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/lsb-release` to check the Ubuntu version
    version: '14.04'
    linux_version: '4.19'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
