
nikita = require '@nikitajs/core'
{tags, ssh, scratch, krb5} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.krb5_addprinc

describe 'krb5.ticket', ->

  they 'create a new principal without a randkey', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'myprecious'
    .system.execute 'kdestroy'
    .krb5.ticket
      principal: "nikita@#{krb5.realm}"
      password: 'myprecious'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ticket
      principal: "nikita@#{krb5.realm}"
      password: 'myprecious'
    , (err, {status}) ->
      status.should.be.false() unless err
    .system.execute
      cmd: 'klist -s'
    .promise()
