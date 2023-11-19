
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.user.enable', ->
  return unless test.tags.ipa
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.enable connection: test.ipa,
        username: 'test_user_enable'
      , ({config: {uid}}) ->
        uid.should.eql 'test_user_enable'
  
  describe 'action', ->
  
    they 'enable a missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.enable connection: test.ipa,
          uid: 'test_user_enable_missing'
        .should.be.rejectedWith
          code: 4001
          message: 'test_user_enable_missing: user not found'
  
    they 'enable an active user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del connection: test.ipa,
          $relax: true
          uid: 'test_user_enable_active'
        await @ipa.user connection: test.ipa,
          uid: 'test_user_enable_active'
          attributes:
            givenname: 'User'
            sn: 'Disable'
            mail: [
              'test_user_enable@nikita.js.org'
            ]
            nsaccountlock: true
        {$status} = await @ipa.user.enable connection: test.ipa,
          uid: 'test_user_enable_active'
        $status.should.be.true()

  they 'enable an inactive user', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @ipa.user.del connection: test.ipa,
        $relax: true
        uid: 'test_user_enable_inactive'
      await @ipa.user connection: test.ipa,
        uid: 'test_user_enable_inactive'
        attributes:
          givenname: 'User'
          sn: 'Disable'
          mail: [
            'test_user_enable@nikita.js.org'
          ]
          nsaccountlock: true
      await @ipa.user.enable connection: test.ipa,
        uid: 'test_user_enable_inactive'
      {$status} = await @ipa.user.enable connection: test.ipa,
        uid: 'test_user_enable_inactive'
      $status.should.be.false()
