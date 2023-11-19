
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

for engine, _ of test.db

  describe "db.user.exists #{engine}", ->
    return unless test.tags.db

    they 'user not created', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.user.remove 'test_user_exists_1_user'
        {exists} = await @db.user.exists
          username: 'test_user_exists_1_user'
        exists.should.be.false()

    they 'with status as false as true', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ({tools: {status}})->
        await @db.user.remove 'test_user_exists_2_user', $shy: true
        await @db.user
          username: 'test_user_exists_2_user'
          password: 'test_user_exists_2_password'
          $shy: true
        {$status} = await @db.user.exists
          username: 'test_user_exists_2_user'
        $status.should.be.true()
        await @db.user.remove 'test_user_exists_2_user', $shy: true
        # Modules of type exists shall be shy
        status().should.be.false()
