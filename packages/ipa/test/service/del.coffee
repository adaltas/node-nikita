
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.service.del', ->
  
  they 'delete a missing service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.del connection: ipa,
      principal: 'test_service_del'
    .ipa.service.del connection: ipa,
      principal: 'test_service_del'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'delete a service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service connection: ipa,
      principal: 'test_service_del/freeipa.nikita.local'
    .ipa.service.del connection: ipa,
      principal: 'test_service_del/freeipa.nikita.local'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
