
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, krb5} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.krb5_delprinc

describe 'krb5.delprinc', ->

  they 'a principal which exists', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'a principal which does not exist', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    , (err, {status}) ->
      status.should.be.false()
    .promise()
