
nikita = require '@nikitajs/engine/src'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

for engine, _ of db

  describe "db.user.exists #{engine}", ->

    they 'user not created', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      , ->
        @db.user.remove 'test_user_exists_1_user'
        {exists} = await @db.user.exists
          username: 'test_user_exists_1_user'
        exists.should.be.false()

    they 'with status as false as true', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      , ({tools: {status}})->
        @db.user.remove 'test_user_exists_2_user', metadata: shy: true
        @db.user
          username: 'test_user_exists_2_user'
          password: 'test_user_exists_2_password'
          metadata: shy: true
        {status: lstatus} = await @db.user.exists
          username: 'test_user_exists_2_user'
        lstatus.should.be.true()
        @db.user.remove 'test_user_exists_2_user', metadata: shy: true
        # Modules of type exists shall be shy
        status().should.be.false()
