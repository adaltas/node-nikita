
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.user', ->
  return unless test.tags.ldap_user

  they 'create a new user', ({ssh}) ->
    nikita
      ldap:
        binddn: test.ldap.binddn
        passwd: test.ldap.passwd
        uri: test.ldap.uri
      $ssh: ssh
    , ->
      await @ldap.delete
        dn: "cn=nikita,#{test.ldap.suffix_dn}"
      {$status} = await @ldap.user
        user:
          dn: "cn=nikita,#{test.ldap.suffix_dn}"
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
      $status.should.be.true()
      await @ldap.delete
        dn: "cn=nikita,#{test.ldap.suffix_dn}"

  they 'detect no change', ({ssh}) ->
    user =
      dn: "cn=nikita,#{test.ldap.suffix_dn}"
      userPassword: 'test'
      uid: 'nikita'
      objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
      uidNumber: '9610'
      gidNumber: '9610'
      homeDirectory: '/home/nikita'
    nikita
      ldap:
        binddn: test.ldap.binddn
        passwd: test.ldap.passwd
        uri: test.ldap.uri
      $ssh: ssh
    , ->
      await @ldap.delete
        dn: "cn=nikita,#{test.ldap.suffix_dn}"
      await @ldap.user
        user: user
      {$status} = await @ldap.user
        user: user
      $status.should.be.false()
      await @ldap.delete
        dn: "cn=nikita,#{test.ldap.suffix_dn}"
