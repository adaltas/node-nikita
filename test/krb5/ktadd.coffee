
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'krb5.ktadd', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_krb5_ktadd

  they 'create a new keytab', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'detect kvno', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_2.keytab"
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'change permission', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      mode: 0o0755
    .krb5.ktadd
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      mode: 0o0707
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
