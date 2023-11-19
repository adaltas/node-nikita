
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.user.del', ->
  return unless test.tags.ipa
  
  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.del connection: test.ipa,
        username: 'test_user_del'

  describe 'action', ->
    
    they 'delete a missing user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user.del connection: test.ipa,
          uid: 'test_user_del'
        {$status} = await @ipa.user.del connection: test.ipa,
          uid: 'test_user_del'
        $status.should.be.false()

    they 'delete a user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        @ipa.user connection: test.ipa,
          uid: 'test_user_del'
          attributes:
            givenname: 'User'
            sn: 'Delete'
            mail: [
              'test_user_del@nikita.js.org'
            ]
        {$status} = await @ipa.user.del connection: test.ipa,
          uid: 'test_user_del'
        $status.should.be.true()
