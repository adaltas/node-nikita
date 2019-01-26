
module.exports =
  tags:
    krb5_addprinc: true
    krb5_delprinc: true
    krb5_ktadd: true
  krb5:
    realm: 'NODE.DC1.CONSUL'
    kadmin_server: 'krb5'
    kadmin_principal: 'admin/admin@NODE.DC1.CONSUL'
    kadmin_password: 'admin'
  ssh:
    host: 'localhost'
    username: 'root'
