
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.service.show', ->

  they 'get single service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.show connection: ipa,
      principal: 'HTTP/freeipa.nikita.local'
    , (err, {result}) ->
      throw err if err
      result.dn.should.eql 'krbprincipalname=HTTP/freeipa.nikita.local@NIKITA.LOCAL,cn=services,cn=accounts,dc=nikita,dc=local'
    .promise()

  they 'get missing service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.show connection: ipa,
      principal: 'missing/freeipa.nikita.local'
      relax: true
    , (err, {result}) ->
      err.code.should.eql 4001
      err.message.should.eql 'missing/freeipa.nikita.local@NIKITA.LOCAL: service not found'
    .promise()
