
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
ldap = require 'ldapjs'

describe 'krb5_addprinc', ->

  config = test.config()
  return unless config.krb5

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
      created.should.be.ok
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      randkey: true
    , (err, created) ->
      created.should.not.be.ok
    # .krb5_delprinc
    #   principal: "mecano@#{config.krb5.realm}"
    #   kadmin_server: config.krb5.kadmin_server
    #   kadmin_principal: config.krb5.kadmin_principal
    #   kadmin_password: config.krb5.kadmin_password
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
      password: 'password'
    , (err, created) ->
      created.should.be.ok
    .krb5_addprinc
      principal: "mecano@#{config.krb5.realm}"
      password: 'password'
    , (err, created) ->
      created.should.not.be.ok
    # .krb5_delprinc
    #   principal: "mecano@#{config.krb5.realm}"
    #   kadmin_server: config.krb5.kadmin_server
    #   kadmin_principal: config.krb5.kadmin_principal
    #   kadmin_password: config.krb5.kadmin_password
    .then next

