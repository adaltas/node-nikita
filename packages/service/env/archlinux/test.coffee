
module.exports =
  tags:
    service_install: true
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  service:
    name: 'ntp'
    srv_name: 'ntpd'
    chk_name: 'ntpd'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
