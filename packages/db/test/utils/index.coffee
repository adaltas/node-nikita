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
      
      it 'set default port engine', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'mariadb'
          host: 'localhost'
        .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\''
    
      it "default arguments", ->
        command
          admin_db: 'root'
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'mariadb'
          host: 'localhost'
          port: 3306
        .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\''
    
      it 'command option', ->
          command
            admin_db: 'root'
            admin_password: 'rootme'
            admin_username: 'root'
            engine: 'mariadb'
            host: 'localhost'
            port: 3306
            command: '''
            show databases;
            '''
          .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\' -e "show databases;"'
        
    describe "using engine: postgresql", ->
      
      it 'set default port engine', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'postgresql'
          host: 'localhost'
        .should.equal 'PGPASSWORD=rootme psql -h localhost -p 5432 -U root -tAq'

      it "default arguments", ->
        command
          admin_db: 'root'
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'postgresql'
          host: 'localhost'
          port: 5432
        .should.equal 'PGPASSWORD=rootme psql -h localhost -p 5432 -U root -tAq'
      
      it 'command option', ->
        command
          admin_db: 'root'
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'postgresql'
          host: 'localhost'
          port: 5432
          command: '''
          show databases;
          '''
        .should.equal 'PGPASSWORD=rootme psql -h localhost -p 5432 -U root -tAq -c "show databases;"'
