
module.exports =
  disable_conditions_if_os: true
  disable_cron: true
  disable_db: false # can be activated
  disable_docker: true
  disable_docker_volume: true # centos6 ship docker 1.7 which doesnt support volume
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
  db:
    postgresql:
      engine: 'postgresql'
      host: 'postgres'
      port: 5432
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  ssh:
    host: 'localhost'
    username: 'root'
