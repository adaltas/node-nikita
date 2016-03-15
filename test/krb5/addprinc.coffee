
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
ldap = require 'ldapjs'

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
