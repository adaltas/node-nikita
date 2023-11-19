
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ldap.database', ->
  return unless test.tags.ldap
  
  describe 'schema', ->
    
    it 'require `suffix`', ->
      nikita.ldap.tools.database
        uri: test.ldap.uri
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config must have required property 'suffix'/
    
    it 'extends ldap.search', ->
      nikita.ldap.tools.database
        uri: invalid: 'value'
        suffix: test.ldap.suffix_dn
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config\/uri must be string/
    
    it 'provide an immutable value to `base`', ->
      nikita.ldap.tools.database
        base: 'invalid'
        suffix: test.ldap.suffix_dn
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /config\/base must be equal to constant, allowedValue is "cn=config"/
      
  
  describe 'usage', ->
  
    they 'create a new index', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {dn, database} = await @ldap.tools.database
          suffix: test.ldap.suffix_dn
          uri: test.ldap.uri
          binddn: test.ldap.config.binddn
          passwd: test.ldap.config.passwd
        dn.should.match /^olcDatabase=\{\d+\}\w+,cn=config$/
        database.should.match /^\{\d+\}\w+$/
