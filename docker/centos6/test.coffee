
module.exports =
  disable_conditions_if_os: false
  disable_cron: false
  disable_db: false # can be activated
  disable_docker: false
  disable_docker_volume: true # centos6 ship docker 1.7 which doesnt support volume
  disable_krb5_addprinc: false # not sure if working
  disable_krb5_delprinc: false # not sure if working
  disable_krb5_ktadd: false # not sure if working
  disable_ldap_acl: true # can be activated
  disable_ldap_index: true # can be activated
  disable_ldap_user: true # can be activated
  disable_service_install: false
  disable_service_startup: false
  disable_service_systemctl: false
  disable_system_chmod: false
  disable_system_cgroups: false
  disable_system_discover: false
  disable_system_execute_arc_chroot: true #can not be activated
  disable_system_limits: false
  disable_system_tmpfs: true #can not be activated
  disable_system_user: false
  disable_tools_repo: false
  disable_tools_rubygems: true
  disable_yum_conf: false
  conditions_is_os:
    arch: '64'
    name: 'centos'
    version: '6.8'
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  db:
    mysql:
      engine: 'mysql'
      host: 'mysql'
      port: 5432
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
    postgres:
      engine: 'postgres'
      host: 'postgres'
      port: 5432
      admin_username: 'root'
      admin_password: 'rootme'
      admin_db: 'root'
  krb5:
    realm: 'NODE.DC1.CONSUL'
    kadmin_server: 'krb5'
    kadmin_principal: 'admin/admin@NODE.DC1.CONSUL'
    kadmin_password: 'admin'
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
