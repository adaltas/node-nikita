
nikita = require '@nikitajs/core'
misc = require '@nikitajs/core/lib/misc'
{tags, ssh, scratch, krb5} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.krb5_ktadd

describe 'krb5.kutil.add', ->

  they 'create a new keytab', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      password: 'nikita123-1'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita.keytab"
      password: 'nikita123-1'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'detect kvno', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
    .krb5.execute
      cmd: """
      change_password -pw nikita123-2 nikita@#{krb5.realm}
      """
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-2'
    , (err, {status}) ->
      status.should.be.true() unless err
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-2'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'change permission', ({ssh}) ->
    nikita
      ssh: ssh
      krb5: admin: krb5
    .krb5.addprinc
      principal: "nikita@#{krb5.realm}"
      randkey: true
      password: 'nikita123-1'
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
      mode: 0o0755
    .krb5.ktutil.add
      principal: "nikita@#{krb5.realm}"
      keytab: "#{scratch}/nikita_1.keytab"
      password: 'nikita123-1'
      mode: 0o0707
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
