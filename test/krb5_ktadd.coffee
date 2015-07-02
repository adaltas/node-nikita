
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
ldap = require 'ldapjs'

describe 'krb5_ktadd', ->

  scratch = test.scratch @
  config = test.config()
  return unless config.krb5

  they 'create a new keytab', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
    , (err, status) ->
      status.should.be.true()
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
    , (err, status) ->
      status.should.be.false()
    .then next

  they 'change permission', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
      mode: 0o0707
    , (err, status) ->
      status.should.be.true()
    .then next


