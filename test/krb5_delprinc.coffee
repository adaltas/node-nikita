
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
test = require './test'
they = require 'ssh2-they'
ldap = require 'ldapjs'

describe 'krb5_delprinc', ->

  config = test.config()
  return unless config.krb5

  they 'a principal which exists', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    , (err, status) ->
      status.should.be.True
    .then next

  they 'a principal which does not exist', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    , (err, status) ->
      status.should.be.False
    .then next

