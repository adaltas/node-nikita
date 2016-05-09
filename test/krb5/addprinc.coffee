
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'krb5_addprinc', ->

  config = test.config()
  return if config.disable_krb5_addprinc

  they 'create a new principal without a randkey', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    , (err, created) ->
      created.should.be.true() unless err
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    , (err, created) ->
      created.should.be.false() unless err
    .then next

  they 'create a new principal with a password', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password1'
    , (err, created) ->
      created.should.be.true()
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, created) ->
      created.should.be.true()
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, created) ->
      created.should.be.false()
    .execute
      cmd: "klist"
      code_skipped: 1
    , (err, executed, stdout, stderr) ->
      stderr.should.match /^(.*)No credentials cache found(.*)/
    .then next

  they 'dont overwrite password', (ssh, next) ->
    mecano
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5_delprinc
      principal: "mecano@#{config.krb5.realm}"
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password1'
    , (err, created) ->
      created.should.be.true()
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password2'
      password_sync: false # Default
    , (err, created) ->
      created.should.be.false()
    .execute
      cmd: "echo password1 | kinit mecano@#{config.krb5.realm}"
    .then next

  they 'call function with new style baby', (ssh, next) ->
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
      password: 'hdfs123'
      password_sync: true
      principal: 'hdfs@NODE.DC1.CONSUL'
    mecano
      ssh: ssh
      # stdout: process.stdout
      # stderr: process.stdout
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .execute 
      cmd: 'rm -f /etc/security/keytabs/zookeeper.service.keytab || true ; exit 0;'
    .krb5_delprinc
      principal: user.principal
    .krb5_delprinc
      principal: "zookeeper/krb5@NODE.DC1.CONSUL"
    .krb5_addprinc krb5, 
      principal: "zookeeper/krb5@NODE.DC1.CONSUL"
      randkey: true
      keytab: '/etc/security/keytabs/zookeeper.service.keytab'
    .krb5_addprinc krb5, user
    , (err, created) ->
      return next err if err  
      created.should.be.true()
      mecano
        ssh: ssh
      .execute
        cmd: """
          echo hdfs123 | kinit hdfs@NODE.DC1.CONSUL" { echo 'coucou' } """
      , (err, executed, stdout) ->
        return next err if err
        execute.should.be.true()
        next()
