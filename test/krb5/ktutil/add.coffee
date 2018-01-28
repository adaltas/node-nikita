
nikita = require '../../../src'
misc = require '../../../src/misc'
test = require '../../test'
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
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      password: 'nikita123-1'
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      password: 'nikita123-1'
    , (err, status) ->
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
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
    .system.execute
      cmd: misc.kadmin config.krb5, """
         change_password -pw nikita123-2 nikita@#{config.krb5.realm}
      """
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-2'
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-2'
    , (err, status) ->
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
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
      mode: 0o0755
    .krb5.ktutil.add
      principal: "nikita@#{config.krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
      mode: 0o0707
    , (err, status) ->
      status.should.be.true() unless err
    .promise()
