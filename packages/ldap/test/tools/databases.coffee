
nikita = require '@nikitajs/engine/lib'
{tags, ssh, ldap} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ldap

describe 'ldap.databases', ->
  
  they 'create a new index', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {databases} = await @ldap.tools.databases
        suffix: ldap.suffix_dn
        uri: ldap.uri
        binddn: ldap.config.binddn
        passwd: ldap.config.passwd
      for database in databases
        database.should.match /^\{-?\d+\}\w+$/
