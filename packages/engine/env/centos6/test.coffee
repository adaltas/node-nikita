
module.exports =
  tags:
    conditions_if_os: true
  conditions_if_os:
    arch: 'x86_64'
    distribution: 'centos'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/redhat-release` to check the Centos version
    version: '6.10'
    linux_version: '4.19'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
