
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.search', ->
  return unless test.tags.ldap

  they 'with scope base', ({ssh}) ->
    nikita
      ldap:
        binddn: test.ldap.binddn
        passwd: test.ldap.passwd
        uri: test.ldap.uri
      $ssh: ssh
    , ->
      {stdout} = await @ldap.search
        base: "#{test.ldap.suffix_dn}"
      stdout.should.containEql 'dn: dc=example,dc=org'
