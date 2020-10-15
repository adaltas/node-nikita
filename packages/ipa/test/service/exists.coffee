
nikita = require '@nikitajs/engine/src'
{tags, ssh, ipa} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.ipa

describe 'ipa.service.exists', ->

  they 'service doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.service.del connection: ipa,
        principal: 'service_exists/freeipa.nikita.local'
      {status, exists} = await @ipa.service.exists connection: ipa,
        principal: 'service_exists/freeipa.nikita.local'
      status.should.be.false()
      exists.should.be.false()

  they 'service exists', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @ipa.service connection: ipa,
        principal: 'service_exists/freeipa.nikita.local'
      {status, exists} = await @ipa.service.exists connection: ipa,
        principal: 'service_exists/freeipa.nikita.local'
      status.should.be.true()
      exists.should.be.true()
      @ipa.service.del connection: ipa,
        principal: 'service_exists/freeipa.nikita.local'
