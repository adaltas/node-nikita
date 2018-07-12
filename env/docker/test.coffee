
module.exports =
  disable_conditions_if_os: true
  disable_cron: true
  disable_db: true # can be activated
  disable_docker: false
  disable_docker_volume: false # centos6 ship docker 1.7 which doesnt support volume
  disable_krb5_addprinc: true # not sure if working
  disable_krb5_delprinc: true # not sure if working
  disable_krb5_ktadd: true # not sure if working
  disable_ldap_acl: true # can be activated
  disable_ldap_index: true # can be activated
  disable_ldap_user: true # can be activated
  disable_service_install: true
  disable_service_startup: true
  disable_service_systemctl: true # cant be activated because systemctl not compatible with Docker
  disable_sudo: true
  disable_system_chmod: true
  disable_system_cgroups: true
  disable_system_discover: true
  disable_system_execute_arc_chroot: true #can not be activated
  disable_system_limits: true
  disable_system_tmpfs: true
  disable_system_user: true
  disable_tools_repo: true
  disable_tools_rubygems: true
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  ssh:
    host: 'localhost'
    username: 'root'
