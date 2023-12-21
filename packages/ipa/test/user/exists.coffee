
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.user.exists', ->
  return unless test.tags.ipa

  describe 'schema', ->

    they 'use `username` as alias for `uid`', ({ssh}) ->
      nikita
        $ssh: ssh
      .ipa.user.exists connection: test.ipa,
        username: 'user_exists'

  describe 'action', ->

    they 'user doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del connection: test.ipa,
          uid: 'user_exists'
        {$status, exists} = await @ipa.user.exists connection: test.ipa,
          uid: 'user_exists'
        $status.should.be.false()
        exists.should.be.false()

    they 'user exists', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user connection: test.ipa,
          uid: 'user_exists'
          attributes:
            givenname: 'Firstname'
            sn: 'Lastname'
            mail: [
              'user@nikita.js.org'
            ]
        {$status, exists} = await @ipa.user.exists connection: test.ipa,
          uid: 'user_exists'
        $status.should.be.true()
        exists.should.be.true()
