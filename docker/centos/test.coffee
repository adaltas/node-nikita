
module.exports =
  disable_docker: false
  disable_krb5_addprinc: false # not sure if working
  disable_krb5_delprinc: false # not sure if working
  disable_krb5_ktadd: false # not sure if working
  disable_ldap_acl: true # can be activated
  disable_ldap_index: true # can be activated
  disable_ldap_user: true # can be activated
  test_service: false # cant be activated
  docker: # eg `docker-machine create --driver virtualbox mecano || docker-machine start mecano`
    host: 'dind:2375'
    # machine: 'mecano'
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
