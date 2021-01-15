
nikita = require '@nikitajs/engine/lib'
{tags, config, ldap} = require '../test'
they = require('mocha-they')(config)

return unless tags.ldap

describe 'ldap.database', ->
  
  they 'create a new index', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {dn, database} = await @ldap.tools.database
        suffix: ldap.suffix_dn
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      dn.should.match /^olcDatabase=\{\d+\}\w+,cn=config$/
      database.should.match /^\{\d+\}\w+$/
