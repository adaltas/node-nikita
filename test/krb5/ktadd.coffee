
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
ldap = require 'ldapjs'

describe 'krb5_ktadd', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_krb5_ktadd

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
      status.should.be.true() unless err
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'detect kvno', (ssh, next) ->
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
      keytab: "#{scratch}/mecano_1.keytab"
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano_2.keytab"
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano_1.keytab"
    , (err, status) ->
      status.should.be.true() unless err
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano_1.keytab"
    , (err, status) ->
      status.should.be.false() unless err
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
      mode: 0o0755
    .krb5_ktadd
      principal: "mecano@#{config.krb5.realm}"
      keytab: "#{scratch}/mecano.keytab"
      mode: 0o0707
    , (err, status) ->
      status.should.be.true() unless err
    .then next
