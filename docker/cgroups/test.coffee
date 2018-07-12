
module.exports =
  disable_conditions_if_os: true
  disable_cron: true
  disable_db: true # can be activated
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
  disable_system_cgroups: false
  disable_system_discover: true
  disable_system_execute_arc_chroot: true #can not be activated
  disable_system_limits: true
  disable_system_tmpfs: true
  disable_system_user: true
  disable_tools_repo: true
  disable_tools_rubygems: true
  conditions_is_os:
    arch: '64'
    name: 'centos'
    version: '7.5'
  ldap:
    uri: 'ldaps://master3.ryba:636'
    binddn: 'cn=Manager,dc=ryba'
    passwd: 'test'
    suffix_dn: 'ou=users,dc=ryba' # used by ldap_user
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
    name: 'cronie'
    srv_name: 'crond'
    chk_name: 'crond'
