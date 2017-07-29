
module.exports =
  disable_conditions_if_os: true
  disable_cron: true
  disable_db: true
  disable_docker: true
  disable_docker_volume: true
  disable_krb5_addprinc: true
  disable_krb5_delprinc: true
  disable_krb5_ktadd: true
  disable_ldap_acl: true
  disable_ldap_index: true
  disable_ldap_user: true
  disable_service_install: true
  disable_service_startup: true
  disable_service_systemctl: true
  disable_system_chmod: true
  disable_system_cgroups: true
  disable_system_discover: true
  disable_system_execute_arc_chroot: true
  disable_system_limits: true
  disable_system_tmpfs: true
  disable_system_user: true
  disable_tools_repo: true
  disable_tools_rubygems: true
  disable_yum_conf: true
  docker: # eg `docker-machine create --driver virtualbox nikita`
    machine: 'nikita'
  krb5:
    realm: 'DOMAIN.COM'
    kadmin_server: 'domain.com'
    kadmin_principal: 'nikita/admin@DOMAIN.COM'
    kadmin_password: 'test'
  ldap:
    url: 'ldap://openldap.domain'
    binddn: 'cn=manager,cn=config'
    passwd: 'test'
    suffix_dn: 'ou=users,dc=domain,dc=com' # used by ldap_user
  ssh:
    host: '127.0.0.1'
    username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
