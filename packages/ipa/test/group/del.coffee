
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.group.del', ->
  return unless test.tags.ipa

  they 'delete a group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.group connection: test.ipa,
        cn: 'group_del'
      {$status} = await @ipa.group.del connection: test.ipa,
        cn: 'group_del'
      $status.should.be.true()
      {$status} = await @ipa.group.del connection: test.ipa,
        cn: 'group_del'
      $status.should.be.false()
