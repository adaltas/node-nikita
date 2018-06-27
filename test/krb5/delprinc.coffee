
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'krb5.delprinc', ->

  config = test.config()
  return if config.disable_krb5_delprinc

  they 'a principal which exists', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.addprinc
      principal: "nikita@#{config.krb5.realm}"
      randkey: true
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'a principal which does not exist', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: config.krb5.kadmin_server
      kadmin_principal: config.krb5.kadmin_principal
      kadmin_password: config.krb5.kadmin_password
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    .krb5.delprinc
      principal: "nikita@#{config.krb5.realm}"
    , (err, {status}) ->
      status.should.be.false()
    .promise()
