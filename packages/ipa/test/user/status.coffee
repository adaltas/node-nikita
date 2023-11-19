
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.user.status', ->
  return unless test.tags.ipa
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
      .ipa.user.status connection: test.ipa,
        username: 'user_status'
      , ({config: {uid}}) ->
        uid.should.eql 'user_status'

  describe 'action', ->

    they 'get single user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {result} = await @ipa.user.status connection: test.ipa,
          uid: 'admin'
        result.dn.should.match /^uid=admin,cn=users,cn=accounts,/

    they 'get missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.status connection: test.ipa,
          uid: 'missing'
        .should.be.rejectedWith
          code: 4001
          message: 'missing: user not found'
