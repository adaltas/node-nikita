
export default
  tags:
    service_install: false
    service_outdated: true
    service_startup: false
    service_systemctl: false
  service:
    name: 'apt'
  config: [
    label: 'remote'
    sudo: true
    ssh:
      host: 'target'
      username: 'nikita'
      password: 'secret'
  ]
