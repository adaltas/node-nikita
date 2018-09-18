
module.exports =
  tags:
    conditions_if_os: false
    service_install: false
    service_startup: false
    service_systemctl: false
    system_chmod: false
    system_cgroups: false
    system_discover: false
    system_info: false
    system_limits: false
    system_user: false
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  conditions_is_os:
    arch: '64'
    name: 'ubuntu'
    version: '14.04'
  ssh:
    host: 'localhost'
    username: 'root'
  service:
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
