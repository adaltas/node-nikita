
module.exports =
  scratch: '/tmp/nikita-test-core'
  tags:
    api: true
    api_if_os: false # disable_conditions_if_os
    conditions_if_os: false
    cron: false # disable_cron
    db: false # disable_db
    docker: false # disable_docker
    docker_volume: false
    krb5_addprinc: false
    krb5_delprinc: false
    krb5_ktadd: false
    ldap_acl: false
    ldap_index: false
    ldap_user: false
    posix: true
    rubygem: false # disable_tools_rubygems
    service_install: false
    service_startup: false
    service_systemctl: false
    sudo: false
    system_chmod: false
    system_cgroups: false
    system_discover: false
    system_execute_arc_chroot: false
    system_info: false
    system_limits: false
    system_tmpfs: false
    tools_repo: false
    tools_rubygems: false
    system_user: false
    yum_conf: false
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
