
module.exports =
  tags:
    conditions_if_os: true
  conditions_if_os:
    arch: 'x86_64'
    distribution: 'centos'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/redhat-release` to check the Centos version
    version: '6.10'
    linux_version: '5.10'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
