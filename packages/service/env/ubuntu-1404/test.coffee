
export default
  tags:
    service_install: true
    service_startup: true
    service_systemctl: false
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
  config: [
    label: 'remote'
    sudo: true
    ssh:
      host: 'target'
      username: 'nikita'
      password: 'secret'
  ]
