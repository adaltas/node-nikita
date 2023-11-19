
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.group.add_member', ->
  return unless test.tags.ipa

  they 'add_member to a group', ({ssh}) ->
    gidnumber = null
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: test.ipa, [
        cn: 'group_add_member'
      ,
        cn: 'group_add_member_user'
      ]
      await @ipa.user.del connection: test.ipa,
        uid: 'group_add_member_user'
      {result} = await @ipa.group connection: test.ipa,
        cn: 'group_add_member'
      gidnumber = result.gidnumber
      await @ipa.user connection: test.ipa,
        uid: 'group_add_member_user'
        attributes:
          givenname: 'Firstname'
          sn: 'Lastname'
          mail: [ 'user@nikita.js.org' ]
      {$status} = await @ipa.group.add_member connection: test.ipa,
        cn: 'group_add_member'
        attributes:
          user: ['group_add_member_user']
      $status.should.be.true()
      {result} = await @ipa.group.show connection: test.ipa,
        cn: 'group_add_member'
      result.gidnumber.should.eql gidnumber
