
nikita = require '@nikitajs/engine/src'
{tags, ssh, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.service.show', ->

  they 'get single service', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      {result} = await @ipa.service.show connection: ipa,
        principal: 'HTTP/freeipa.nikita.local'
      result.dn.should.eql 'krbprincipalname=HTTP/freeipa.nikita.local@NIKITA.LOCAL,cn=services,cn=accounts,dc=nikita,dc=local'

  they 'get missing service', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.service.show connection: ipa,
        principal: 'missing/freeipa.nikita.local'
      .should.be.rejectedWith
        code: 4001
        message: 'missing/freeipa.nikita.local@NIKITA.LOCAL: service not found'
