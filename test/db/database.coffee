
nikita = require '../../src'
db = require '../../src/misc/db'
test = require '../test'
they = require 'ssh2-they'
each = require 'each'

config = test.config()
return if config.disable_db
for engine, _ of config.db

  describe "db.database #{engine}", ->

    they 'add new database', (ssh) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'postgres_db_0a'
      .db.database.remove 'postgres_db_0b'
      .db.database database: 'postgres_db_0a'
      .db.database 'postgres_db_0b'
      .db.database.remove 'postgres_db_0a'
      .db.database.remove 'postgres_db_0b'
      .promise()
      
    they 'status not modified new database', (ssh) ->
      nikita
        ssh: ssh
        db: config.db[engine]
      .db.database.remove 'postgres_db_1'
      .db.database 'postgres_db_1'
      .db.database 'postgres_db_1', (err, status) ->
        status.should.be.false() unless err
      .db.database.remove 'postgres_db_1'
      .promise()

    describe 'user', ->

      they 'which is existing', (ssh) ->
        nikita
          ssh: ssh
          db: config.db[engine]
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
            when 'mysql' then db.cmd(config.db[engine], database: 'mysql', "SELECT user FROM db WHERE db='postgres_db_3';") + " | grep 'postgres_user_3'"
            when 'postgres' then db.cmd(config.db[engine], database: 'postgres_db_3', '\\l') + " | egrep '^postgres_user_3='"
        , (err, status) ->
          status.should.be.true() unless err
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .promise()

      they 'honors status', (ssh) ->
        nikita
          ssh: ssh
          db: config.db[engine]
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
        , (err, status) ->
          status.should.be.true()
        .db.database
          database: 'postgres_db_3'
          user: 'postgres_user_3'
        , (err, status) ->
          status.should.be.false()
        .db.database.remove 'postgres_db_3'
        .db.user.remove 'postgres_user_3'
        .promise()

      they 'which is not existing', (ssh) ->
        nikita
          ssh: ssh
          db: config.db[engine]
        .db.database.remove 'postgres_db_4'
        .db.user.remove 'postgres_user_4'
        .db.database
          database: 'postgres_db_4'
          user: 'postgres_user_4'
          relax: true
        , (err, status) ->
          err.message.should.eql 'DB user does not exists: postgres_user_4'
        .db.database.remove 'postgres_db_4'
        .db.user.remove 'postgres_user_4'
        .promise()
