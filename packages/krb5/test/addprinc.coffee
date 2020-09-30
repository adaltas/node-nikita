
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch, krb5} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.krb5_addprinc

describe 'krb5.addprinc', ->
  
  it 'validate schema', ->
    nikita
    .krb5.addprinc
      relax: true
      options: {}
    , (err) ->
      err.errors.map( (err) -> err.message).should.eql [
        'data should have required property \'admin\''
        'data should have required property \'principal\''
      ]
    .krb5.addprinc
      relax: true
      options:
        admin:
          principal: null
        principal: 'nikita@REALM'
        randkey: true
    , (err) ->
      err.message.should.eql 'data.admin.principal should be string'
    .promise()

  they 'create a new principal without a randkey', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'create a new principal with a password', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'password1'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'password2'
      password_sync: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'dont overwrite password', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.delprinc
      principal: "nikita@#{krb5.realm}"
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'password1'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'password2'
      password_sync: false # Default
    , (err, {status}) ->
      status.should.be.false() unless err
    .system.execute
      cmd: "echo password1 | kinit nikita@#{krb5.realm}"
    .promise()

  they 'call function with new style', ({ssh}) ->
    user =
      password: 'user123'
      password_sync: true
      principal: 'user2@NODE.DC1.CONSUL'
    nikita
      ssh: ssh
      krb5: admin: krb5
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
    .krb5.addprinc user, (err, {status}) ->
      status.should.be.true() unless err
    .system.execute
      cmd: "echo #{user.password} | kinit #{user.principal}"
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
