
nikita = require '../../src'
krb5 = require '../../src/misc/krb5'
test = require '../test'
they = require 'ssh2-they'

describe 'krb5.ticket', ->

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
      password: 'myprecious'
    .system.execute 'kdestroy'
    .krb5.ticket
      principal: "nikita@#{config.krb5.realm}"
      password: 'myprecious'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ticket
      principal: "nikita@#{config.krb5.realm}"
      password: 'myprecious'
    , (err, {status}) ->
      status.should.be.false() unless err
    .system.execute
      cmd: 'klist -s'
    .promise()
