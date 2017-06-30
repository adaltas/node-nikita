
module.exports =
  disable_conditions_if_os: false
  disable_cron: false
  disable_discover: false # can be activated
  disable_docker: true
  disable_krb5_addprinc: false # not sure if working
  disable_krb5_delprinc: false # not sure if working
  disable_krb5_ktadd: false # not sure if working
  disable_ldap_acl: true # can be activated
  disable_ldap_index: true # can be activated
  disable_ldap_user: true # can be activated
  disable_service_install: false
  disable_service_start: false
  disable_service_startup: false
  disable_db: true # can be activated
  disable_system_chmod: false
  disable_system_execute_arc_chroot: true #can not be activated
  disable_system_tmpfs: true #can not be activated
  disable_system_user: false
  disable_tools_repo: true
  disable_yum_conf: true
  docker: # eg `docker-machine create --driver virtualbox nikita || docker-machine start nikita`
    host: 'dind:2375'
    # machine: 'nikita'
  conditions_is_os:
    arch: '64'
    name: 'ubuntu'
    version: '14.04'
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
    name: 'nginx-light'
    srv_name: 'nginx'
    chk_name: 'nginx'
