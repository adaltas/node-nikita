
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ipa} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.ipa

describe 'ipa.service', ->
  
  they 'create a service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.del
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    .ipa.service
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    , (err, {status}) ->
      status.should.be.true() unless err
    .ipa.service.del
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    .promise()

  they 'create an existing service', ({ssh}) ->
    nikita
      ssh: ssh
    .ipa.service.del
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    .ipa.service
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    .ipa.service
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    , (err, {status}) ->
      status.should.be.false() unless err
    .ipa.service.del
      principal: 'service_add/freeipa.nikita.local',
      connection: ipa
    .promise()
