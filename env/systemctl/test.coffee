
module.exports =
  tags:
    service_install: true
    service_startup: true
    service_systemctl: true # cant be activated because systemctl not compatible with Docker
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
