
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.service', ->
  return unless test.tags.ipa
  
  they 'create a service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service.del
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
      {$status} = await @ipa.service
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
      $status.should.be.true()
      await @ipa.service.del
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa

  they 'create an existing service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service.del
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
      await @ipa.service
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
      {$status} = await @ipa.service
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
      $status.should.be.false()
      await @ipa.service.del
        principal: 'service_add/ipa.nikita.local',
        connection: test.ipa
