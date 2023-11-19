
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.group.exists', ->
  return unless test.tags.ipa

  they 'group doesnt exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group.del connection: test.ipa,
        cn: 'group_exists'
      {$status, exists} = await @ipa.group.exists connection: test.ipa,
        cn: 'group_exists'
      $status.should.be.false()
      exists.should.be.false()

  they 'group exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group connection: test.ipa,
        cn: 'group_exists'
      {$status, exists} = await @ipa.group.exists connection: test.ipa,
        cn: 'admins'
      $status.should.be.true()
      exists.should.be.true()
