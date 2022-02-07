
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false # cant be activated because systemctl not compatible with Docker
  service:
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
  config: [
    label: 'remote'
    sudo: true
    ssh:
      host: 'target', username: 'nikita',
      # private_key_path: '~/.ssh/id_rsa'
      password: 'secret'
  ]
