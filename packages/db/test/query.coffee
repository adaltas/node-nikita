
nikita = require '@nikitajs/core'
{jdbc} = require '../src/query'
{tags, ssh, db} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.db

describe "db.query", ->
  
  for engine, _ of db then do (engine) ->

    describe "#{engine}", ->

      they 'schema required', ({ssh}) ->
        nikita
          ssh: ssh
        .db.query
          cmd: 'select * from doesntmatter'
          relax: true
        , (err, {stdout}) ->
          err.message.should.eql 'Invalid Options'
          err.errors.map( (err) -> err.message).should.eql [
            'data should have required property \'admin_username\''
            'data should have required property \'admin_password\''
            'data should have required property \'engine\''
            'data should have required property \'host\''
          ]
        .promise()

      they 'option cmd', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'test_query_1'
        .db.database 'test_query_1'
        .db.query
          database: 'test_query_1'
          cmd: """
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          select * from a_table
          """
        , (err, {status, stdout}) ->
          status.should.be.true()
          stdout.should.eql 'value\n' unless err
        .promise()

      they 'option trim', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'test_query_1'
        .db.database 'test_query_1'
        .db.query
          database: 'test_query_1'
          cmd: """
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          select * from a_table
          """
          trim: true
        , (err, {stdout}) ->
          stdout.should.eql 'value' unless err
        .promise()

      they 'option grep', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'test_query_1'
        .db.database 'test_query_1'
        .db.query
          database: 'test_query_1'
          cmd: '''
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          '''
        .db.query
          database: 'test_query_1'
          cmd: '''
          select * from a_table
          '''
          grep: 'value'
        , (err, {status}) ->
          status.should.be.true()
        .db.query
          database: 'test_query_1'
          cmd: 'select * from a_table'
          grep: 'invalid value'
        , (err, {status}) ->
          status.should.be.false()
        .promise()

      they 'option egrep', ({ssh}) ->
        nikita
          ssh: ssh
          db: db[engine]
        .db.database.remove 'test_query_1'
        .db.database 'test_query_1'
        .db.query
          database: 'test_query_1'
          cmd: '''
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          '''
        .db.query
          database: 'test_query_1'
          cmd: 'select * from a_table'
          egrep: /^val.*$/
        , (err, {status}) ->
          status.should.be.true()
        .db.query
          database: 'test_query_1'
          cmd: 'select * from a_table'
          egrep: /^val$/
        , (err, {status}) ->
          status.should.be.false()
        .promise()

  describe 'jdbc', ->

    it 'get default port', ->
      jdbc('jdbc:mysql://localhost/my_db').should.eql
        engine: 'mysql',
        addresses: [ { host: 'localhost', port: 3306 } ],
        database: 'my_db'
      jdbc('jdbc:postgresql://localhost/my_db').should.eql
        engine: 'postgresql',
        addresses: [ { host: 'localhost', port: 5432 } ],
        database: 'my_db'

    it 'get database', ->
      jdbc('jdbc:mysql://master3.ryba:3306/my_db?a_param=true').database.should.eql 'my_db'
