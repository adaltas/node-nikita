
nikita = require '@nikitajs/engine/lib'
{tags, ssh, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa


describe 'ipa.service', ->
  
  they 'create a service', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.service.del
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
      {status} = await @ipa.service
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
      status.should.be.true()
      @ipa.service.del
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa

  they 'create an existing service', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.service.del
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
      @ipa.service
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
      {status} = await @ipa.service
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
      status.should.be.false()
      @ipa.service.del
        principal: 'service_add/freeipa.nikita.local',
        connection: ipa
