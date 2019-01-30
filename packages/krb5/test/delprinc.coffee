
nikita = require '@nikitajs/core'
{tags, ssh, scratch, krb5} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.krb5_delprinc

describe 'krb5.delprinc', ->

  they 'a principal which exists', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: krb5.kadmin_server
      kadmin_principal: krb5.kadmin_principal
      kadmin_password: krb5.kadmin_password
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'a principal which does not exist', (ssh) ->
    nikita
      ssh: ssh
      kadmin_server: krb5.kadmin_server
      kadmin_principal: krb5.kadmin_principal
      kadmin_password: krb5.kadmin_password
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    , (err, {status}) ->
      status.should.be.false()
    .promise()
