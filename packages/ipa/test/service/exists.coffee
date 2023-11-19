
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.service.exists', ->
  return unless test.tags.ipa

  they 'service doesnt exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service.del connection: test.ipa,
        principal: 'service_exists/ipa.nikita.local'
      {$status, exists} = await @ipa.service.exists connection: test.ipa,
        principal: 'service_exists/ipa.nikita.local'
      $status.should.be.false()
      exists.should.be.false()

  they 'service exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service connection: test.ipa,
        principal: 'service_exists/ipa.nikita.local'
      {$status, exists} = await @ipa.service.exists connection: test.ipa,
        principal: 'service_exists/ipa.nikita.local'
      $status.should.be.true()
      exists.should.be.true()
      @ipa.service.del connection: test.ipa,
        principal: 'service_exists/ipa.nikita.local'
