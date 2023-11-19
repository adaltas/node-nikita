
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.service.del', ->
  return unless test.tags.ipa
  
  they 'delete a missing service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service.del connection: test.ipa,
        principal: 'test_service_del'
      {$status} = await @ipa.service.del connection: test.ipa,
        principal: 'test_service_del'
      $status.should.be.false()

  they 'delete a service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.service connection: test.ipa,
        principal: 'test_service_del/ipa.nikita.local'
      {$status} = await @ipa.service.del connection: test.ipa,
        principal: 'test_service_del/ipa.nikita.local'
      $status.should.be.true()
