
module.exports =
  tags:
    api: true
    ldap: false
    ldap_acl: false
    ldap_index: false
    ldap_user: false
  ldap:
    uri: 'ldap://localhost:389'
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
