
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.databases', ->
  return unless test.tags.ldap
  
  they 'create a new index', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {databases} = await @ldap.tools.databases
        suffix: test.ldap.suffix_dn
        uri: test.ldap.uri
        binddn: test.ldap.config.binddn
        passwd: test.ldap.config.passwd
      for database in databases
        database.should.match /^\{-?\d+\}\w+$/
