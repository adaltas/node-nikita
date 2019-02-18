
nikita = require '@nikitajs/core'
misc = require '@nikitajs/core/src/misc'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

for engine, _ of db then do (engine) ->

  describe "db.database #{engine}", ->

    they 'add new database', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      .db.database.remove 'postgres_db_0a'
      .db.database.remove 'postgres_db_0b'
      .db.database database: 'postgres_db_0a'
      .db.database 'postgres_db_0b'
      .db.database.remove 'postgres_db_0a'
      .db.database.remove 'postgres_db_0b'
      .promise()

    they 'status not modified new database', ({ssh}) ->
      nikita
        ssh: ssh
        db: db[engine]
      .db.database.remove 'postgres_db_1'
      .db.database 'postgres_db_1'
      .db.database 'postgres_db_1', (err, {status}) ->
        status.should.be.false() unless err
      .db.database.remove 'postgres_db_1'
      .promise()

    describe 'user', ->

      they 'which is existing', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .db.user
          username: 'postgres_user_3'
          password: 'postgres_user_3'
        .db.database
          database: 'postgres_db_3'
          user: 'postgres_user_3'
        .system.execute
          cmd: switch engine
            when 'mariadb', 'mysql' then misc.db.cmd(db[engine], database: 'mysql', "SELECT user FROM db WHERE db='postgres_db_3';") + " | grep 'postgres_user_3'"
            when 'postgresql' then misc.db.cmd(db[engine], database: 'postgres_db_3', '\\l') + " | egrep '^postgres_user_3='"
        , (err, {status}) ->
          status.should.be.true() unless err
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .promise()

      they 'honors status', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .db.user
          username: 'postgres_user_3'
          password: 'postgres_user_3'
        .db.database
          database: 'postgres_db_3'
        .db.database
          database: 'postgres_db_3'
          user: 'postgres_user_3'
        , (err, {status}) ->
          status.should.be.true()
        .db.database
          database: 'postgres_db_3'
          user: 'postgres_user_3'
        , (err, {status}) ->
          status.should.be.false()
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .promise()

      they 'which is not existing', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'postgres_db_4'
        .db.user.remove 'postgres_user_4'
        .db.database
          database: 'postgres_db_4'
          user: 'postgres_user_4'
          relax: true
        , (err) ->
          err.message.should.eql 'DB user does not exists: postgres_user_4'
        .db.database.remove 'postgres_db_4'
        .db.user.remove 'postgres_user_4'
        .promise()
