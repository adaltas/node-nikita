
module.exports =
  tags:
    conditions_if_os: true
  conditions_if_os:
    arch: 'x86_64'
    distribution: 'ubuntu'
    # change the minor version according to the latest used in the Dockerfile,
    # run `cat /etc/lsb-release` to check the Ubuntu version
    version: '14.04'
    linux_version: '4.19'
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_rsa'
  ]
