
module.exports =
  disable_conditions_if_os: false
  disable_cron: true
  disable_db: true # can be activated
  disable_docker: true
  disable_docker_volume: true
  disable_krb5_addprinc: true
  disable_krb5_delprinc: true
  disable_krb5_ktadd: true
  disable_ldap_acl: true # can be activated
  disable_ldap_index: true # can be activated
  disable_ldap_user: true # can be activated
  disable_service_install: false
  disable_service_startup: true
  disable_service_systemctl: true # cant be activated because systemctl not compatible with Docker
  disable_sudo: true
  disable_system_chmod: false
  disable_system_cgroups: false
  disable_system_discover: false
  disable_system_execute_arc_chroot: false
  disable_system_info: false
  disable_system_limits: false
  disable_system_tmpfs: true #can not be activated
  disable_system_user: false
  disable_tools_repo: true
  disable_tools_rubygems: true
  conditions_is_os:
    arch: '64'
    name: 'arch'
    version: '4.10.0-1'
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  #ssh:
  #  host: '127.0.0.1'
  #  username: process.env.USER
  #ssh_example:
  #  host: '172.16.134.11'
  #  username: 'root'
  #  uid: 'wdavidw'
  #  gid: 'wdavidw'
  ssh:
    host: 'localhost'
    username: 'root'
  service:
    name: 'ntp'
    srv_name: 'ntpd'
    chk_name: 'ntpd'
