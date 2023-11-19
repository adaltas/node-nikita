
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.schema', ->
  return unless test.tags.ldap
  
  they 'entry with password', ({ssh}) ->
    nikita
      ldap:
        binddn: test.ldap.binddn
        passwd: test.ldap.passwd
        uri: test.ldap.uri
      $ssh: ssh
    , ->
      entry =
        dn: "cn=nikita,#{test.ldap.suffix_dn}"
        userPassword: 'secret'
        uid: 'nikita'
        objectClass: [ 'top', 'account', 'posixAccount' ]
        uidNumber: '9610'
        gidNumber: '9610'
        homeDirectory: '/home/nikita'
      operations = [
        dn: entry.dn
        changetype: 'modify'
        attributes: [
          type: 'replace'
          name: 'userPassword'
          value: 'newsecret'
        ]
      ]
      await @ldap.delete
        dn: entry.dn
      {$status} = await @ldap.add
        entry: entry
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.true()
      {$status} = await @ldap.modify
        operations: operations
      $status.should.be.false()
      await @ldap.delete
        dn: entry.dn
    