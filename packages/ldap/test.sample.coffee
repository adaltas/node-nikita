
module.exports =
  tags:
    ldap_acl: false
    ldap_index: false
    ldap_user: false
  ssh:
    host: '127.0.0.1'
    username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
