
nikita = require '@nikitajs/engine/src'
{tags, ssh, ldap} = require '../test'
they = require('ssh2-they').configure ssh

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
