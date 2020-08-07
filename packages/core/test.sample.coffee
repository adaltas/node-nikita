
module.exports =
  tags:
    api: true
    api_if_os: false # disable_conditions_if_os
    conditions_if_os: false
    posix: true
    service_install: false
    service_startup: false
    service_systemctl: false
    sudo: false
    system_authconfig: false
    system_chmod: false
    system_cgroups: false
    system_discover: false
    system_execute_arc_chroot: false
    system_info: false
    system_limits: false
    system_tmpfs: false
    system_user: false
  ssh: [
    null
  ,
    ssh: host: '127.0.0.1', username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
    # Exemple with vagrant:
    # ssh:
    #   host: '127.0.0.1', port: 2222, username: 'vagrant'
    #   private_key_path: "#{require('os').homedir()}/.vagrant.d/insecure_private_key"
  ]
