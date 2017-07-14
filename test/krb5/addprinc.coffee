
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'krb5.addprinc', ->

  config = test.config()
  return if config.disable_krb5_addprinc

  they 'create a new principal without a randkey', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'create a new principal with a password', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      password: 'password1'
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, status) ->
      status.should.be.false() unless err
    .then next

  they 'dont overwrite password', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      password: 'password1'
    , (err, status) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      password: 'password2'
      password_sync: false # Default
    , (err, status) ->
      status.should.be.false() unless err
    .system.execute
      cmd: "echo password1 | kinit nikita@#{config.krb5.realm}"
    .then next

  they 'call function with new style', (ssh) ->
    krb5 =    
      etc_krb5_conf:
        libdefaults: 
          default_realm: 'NODE.DC1.CONSUL'
        realms: 
          'NODE.DC1.CONSUL':
            kadmin_server: 'krb5'
            kadmin_principal: 'admin/admin@NODE.DC1.CONSUL'
            kadmin_password: 'admin'
        domain_realm: 
          ryba: 'NODE.DC1.CONSUL'
      kdc_conf: 
        realms: 
          'NODE.DC1.CONSUL':
            kadmin_server: 'krb5'
            kadmin_principal: 'admin/admin@NODE.DC1.CONSUL'
            kadmin_password: 'admin'
    user =
      password: 'user123'
      password_sync: true
      principal: 'user2@NODE.DC1.CONSUL'
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .system.execute 
      cmd: 'rm -f /etc/security/keytabs/user1.service.keytab || true ; exit 0;'
    .krb5.delprinc
      principal: user.principal
    .krb5.delprinc
      principal: "user1/krb5@NODE.DC1.CONSUL"
    .krb5.addprinc krb5, 
      principal: "user1/krb5@NODE.DC1.CONSUL"
      randkey: true
      keytab: '/etc/security/keytabs/user1.service.keytab'
    .krb5.addprinc krb5, user
    , (err, status) ->
      status.should.be.true() unless err
    .system.execute
      cmd: "echo #{user.password} | kinit #{user.principal}"
    , (err, status, stdout) ->
      status.should.be.true() unless err
    .then next
