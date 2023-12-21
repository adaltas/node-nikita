
import {merge} from 'mixme'
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.group', ->
  return unless test.tags.ipa

  they 'create a group', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: test.ipa,
        cn: 'group_add'
      {$status} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
      $status.should.be.true()
      {$status} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
      $status.should.be.false()

  they 'attribute option', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: test.ipa,
        cn: 'group_add'
      {$status} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
      $status.should.be.true()
      {$status} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
        attributes:
          description: 'group_add description'
      $status.should.be.true()

  they 'print result such as gidnumber', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: test.ipa,
        cn: 'group_add'
      {$status, result} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
      $status.should.be.true()
      result.gidnumber.length.should.eql 1
      result = merge result, ipauniqueid: null, gidnumber: null
      result.should.eql
        objectclass: [
          'top'
          'groupofnames'
          'nestedgroup'
          'ipausergroup'
          'ipaobject'
          'posixgroup'
          'ipantgroupattrs'
        ]
        dn: 'cn=group_add,cn=groups,cn=accounts,dc=nikita,dc=local'
        gidnumber: null
        cn: [ 'group_add' ]
        ipauniqueid: null

  they 'print result even if no modification is performed', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.group.del connection: test.ipa,
        cn: 'group_add'
      await @ipa.group connection: test.ipa,
        cn: 'group_add'
      {$status, result} = await @ipa.group connection: test.ipa,
        cn: 'group_add'
      $status.should.be.false()
      result.gidnumber.length.should.eql 1
      result = merge result, ipauniqueid: null, gidnumber: null
      result.should.eql
        dn: 'cn=group_add,cn=groups,cn=accounts,dc=nikita,dc=local'
        gidnumber: null
        cn: [ 'group_add' ]
        ipauniqueid: null
