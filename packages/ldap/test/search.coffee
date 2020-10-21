
nikita = require '@nikitajs/engine/src'
{tags, ssh, ldap} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.ldap

describe 'ldap.search', ->

  they 'with scope base', ({ssh}) ->
    nikita
      ldap:
        binddn: ldap.binddn
        passwd: ldap.passwd
        uri: ldap.uri
      ssh: ssh
    , ->
      {stdout} = await @ldap.search
        base: "#{ldap.suffix_dn}"
      stdout.should.containEql 'dn: dc=example,dc=org'
