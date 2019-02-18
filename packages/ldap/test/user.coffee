
nikita = require '@nikitajs/core'
{tags, ssh, ldap} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.ldap_user

describe 'ldap.user', ->

  it 'create a new user', ->
    @timeout 100000
    nikita
      binddn: ldap.binddn
      passwd: ldap.passwd
      uri: ldap.uri
    .ldap.user
      user:
        dn: "cn=nikita,#{ldap.suffix_dn}"
        userPassword: 'test'
        uid: 'nikita'
        objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
        shadowLastChange: '15140'
        shadowMin: '0'
        shadowMax: '99999'
        shadowWarning: '7'
        loginShell: '/bin/bash'
        uidNumber: '9610'
        gidNumber: '9610'
        homeDirectory: '/home/nikita'
    .next (err, {status}) ->
      throw err if err
      status.should.be.true()
    .ldap.delete
      dn: "cn=nikita,#{ldap.suffix_dn}"
    .promise()

  it 'detect no change', ->
    @timeout 100000
    user =
      dn: "cn=nikita,#{ldap.suffix_dn}"
      userPassword: 'test'
      uid: 'nikita'
      objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
      shadowLastChange: '15140'
      shadowMin: '0'
      shadowMax: '99999'
      shadowWarning: '7'
      loginShell: '/bin/bash'
      uidNumber: '9610'
      gidNumber: '9610'
      homeDirectory: '/home/nikita'
    nikita
      binddn: ldap.binddn
      passwd: ldap.passwd
      uri: ldap.uri
    .ldap.user
      user: user
    .next ->
      return # reset status
    .ldap.user
      user: user
    .next (err, {status}) ->
      throw err if err
      status.should.be.false()
    .ldap.delete
      dn: "cn=nikita,#{ldap.suffix_dn}"
    .promise()
