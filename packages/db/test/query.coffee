
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
  
for engine, _ of test.db then do (engine) ->

  describe "db.query #{engine}", ->
    return unless test.tags.db

    they 'schema required', ({ssh}) ->
      nikita
        $ssh: ssh
      .db.query
        command: 'select * from doesntmatter'
      .should.be.rejectedWith [
        "NIKITA_SCHEMA_VALIDATION_CONFIG:"
        "multiple errors were found in the configuration of action `db.query`:"
        "#/required config must have required property 'admin_password';"
        "#/required config must have required property 'admin_username';"
        "#/required config must have required property 'engine';"
        "#/required config must have required property 'host'."
      ].join ' '

    they 'config command', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'test_query_1'
        await @db.database 'test_query_1'
        {$status, stdout} = await @db.query
          database: 'test_query_1'
          command: """
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          select * from a_table
          """
        $status.should.be.true()
        stdout.should.eql 'value\n'

    they 'config trim', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'test_query_1'
        await @db.database 'test_query_1'
        {stdout} = await @db.query
          database: 'test_query_1'
          command: """
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          select * from a_table
          """
          trim: true
        stdout.should.eql 'value'

    they 'config grep with string', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'test_query_1'
        await @db.database 'test_query_1'
        await @db.query
          database: 'test_query_1'
          command: '''
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          '''
        {$status} = await @db.query
          database: 'test_query_1'
          command: '''
          select * from a_table
          '''
          grep: 'value'
        $status.should.be.true()
        {$status} = await @db.query
          database: 'test_query_1'
          command: 'select * from a_table'
          grep: 'invalid value'
        $status.should.be.false()

    they 'config grep with regexp', ({ssh}) ->
      nikita
        $ssh: ssh
        db: test.db[engine]
      , ->
        await @db.database.remove 'test_query_1'
        await @db.database 'test_query_1'
        await @db.query
          database: 'test_query_1'
          command: '''
          CREATE TABLE a_table (a_col CHAR(5));
          INSERT INTO a_table (a_col) VALUES ('value');
          '''
        {$status} = await @db.query
          database: 'test_query_1'
          command: 'select * from a_table'
          grep: /^val.*$/
        $status.should.be.true()
        {$status} = await @db.query
          database: 'test_query_1'
          command: 'select * from a_table'
          grep: /^val$/
        $status.should.be.false()
