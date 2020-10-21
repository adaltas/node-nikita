
module.exports =
  tags:
    api: true
    ldap: true
    ldap_acl: true
    ldap_index: true
    ldap_user: true
  ldap:
    uri: 'ldap://openldap:389'
    binddn: 'cn=admin,dc=example,dc=org'
    passwd: 'admin'
    config:
      binddn: 'cn=admin,cn=config'
      passwd: 'config'
    suffix_dn: 'dc=example,dc=org'
  ssh: [
    null
  ,
    ssh: host: '127.0.0.1', username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
  ]
