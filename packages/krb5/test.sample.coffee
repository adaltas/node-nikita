
module.exports =
  tags:
    api: false
    krb5: false
    krb5_addprinc: false
    krb5_delprinc: false
    krb5_ktadd: false
  krb5:
    realm: 'DOMAIN.COM'
    kadmin_server: 'domain.com'
    kadmin_principal: 'nikita/admin@DOMAIN.COM'
    kadmin_password: 'test'
  ssh: [
    null
  ,
    ssh: host: '127.0.0.1', username: process.env.USER
    # no password, will use private key
    # if found in "~/.ssh/id_rsa"
  ]
