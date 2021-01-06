
module.exports =
  tags:
    api: true
    conditions_if_os: true
    posix: true
  conditions_if_os:
    arch: '64'
    name: 'centos'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/redhat-release` to check the Centos version
    version: '7.9'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
