
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
  config: [
    label: 'local'
    sudo: true
  ,
    label: 'remote'
    sudo: true
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_ed25519'
  ]
