{db} = require '../test'
utils = require '../../src/utils'
{command, escape, jdbc} = utils.db

describe "db.utils", ->
  
  describe "escape", ->
  
    it 'backslashes', ->
      escape('\\').should.eql '\\\\'
  
    it 'double quotes', ->
      escape('"').should.eql '\\"'
  
    it 'backslashes and double quotes', ->
      query = 'SELECT * FROM my_db WHERE name = "John\\\'s"'
      expected = 'SELECT * FROM my_db WHERE name = \\"John\\\\\'s\\"'
      escape(query).should.eql expected
      
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
          
  describe 'command', ->
    
    it 'invalid engine', ->
      () -> command
        engine: 'invalid_engine'
      .should.throw 'Unsupported engine: "invalid_engine"'
      
    describe "using engine: mariadb", ->
      return unless db.mariadb?
    
      it 'set default port engine', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'mariadb'
          host: 'localhost'
        .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\''
    
      it "default arguments", ->
        command(db.mariadb).should.equal expected = [
          "mysql"
          "-h#{db.mariadb.host}"
          "-P#{db.mariadb.port}"
          "-u#{db.mariadb.admin_username}"
          "-p'#{db.mariadb.admin_password}'"
        ].join ' '
    
      it 'command option', ->
          command
            command: '''
            show databases;
            '''
            db.mariadb
          .should.equal [
            "mysql"
            "-h#{db.mariadb.host}"
            "-P#{db.mariadb.port}"
            "-u#{db.mariadb.admin_username}"
            "-p'#{db.mariadb.admin_password}'"
            "-e \"#{escape 'show databases;'}\""
          ].join ' '
        
    describe "using engine: postgresql", ->
      return unless db.postgresql?
      
      it 'set default port engine', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'postgresql'
          host: 'localhost'
        .should.equal 'PGPASSWORD=rootme psql -h localhost 
        -p 5432 -U root -tAq'

      it "default arguments", ->
        command(db.postgresql).should.equal [
          "PGPASSWORD=#{db.postgresql.admin_password}"
          "psql"
          "-h #{db.postgresql.host}"
          "-p #{db.postgresql.port}"
          "-U #{db.postgresql.admin_username}"
          "-tAq"
          ].join ' '      
      
      it 'command option', ->
        command
          command: '''
          show databases;
          '''
          db.postgresql
        .should.equal [
          "PGPASSWORD=#{db.postgresql.admin_password}"
          "psql"
          "-h #{db.postgresql.host}"
          "-p #{db.postgresql.port}"
          "-U #{db.postgresql.admin_username}"
          "-tAq"
          "-c \"#{'show databases;'}\""
          ].join ' '
