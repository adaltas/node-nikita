
module.exports =
  tags:
    posix: true
    conditions_if_os: true
    service_install: true
    system_chmod: true
    system_cgroups: true
    system_discover: true
    system_execute_arc_chroot: true
    system_info: true
    system_limits: true
    system_user: true
  ssh:
    host: 'localhost'
    username: 'root'
  conditions_is_os:
    arch: '64'
    name: 'arch'
    version: '4.10.0-1'
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  service:
    name: 'ntp'
    srv_name: 'ntpd'
    chk_name: 'ntpd'
  ssh: [
    null
  ,
    ssh: host: 'localhost', username: 'root'
  ]
