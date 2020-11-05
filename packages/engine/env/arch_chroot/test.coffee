
module.exports =
  tags:
    conditions_if_os: true
    system_execute_arc_chroot: true
  conditions_if_os:
    arch: '64'
    name: 'arch'
    version: '4.10.0-1'
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  ssh: [
    null
    { ssh: host: 'localhost', username: 'root' }
  ]
