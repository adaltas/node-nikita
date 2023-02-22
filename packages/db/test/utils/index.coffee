utils = require '../../src/utils'
{command, escape, jdbc} = utils.db

describe 'db.utils', ->
  
  describe 'escape', ->
  
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
        admin_password: 'rootme'
        admin_username: 'root'
        host: 'localhost'
        engine: 'invalid_engine'
      .should.throw 'Unsupported engine: "invalid_engine"'
    
    it 'required arguments', ->
      
        () -> command
          admin_password: 'rootme'
          host: 'local'
          engine: 'mariadb'
        .should.throw
          code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
          message: [
            'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
            'Missing required argument: "admin_username"'
          ].join ' '
        
        () -> command
          admin_username: 'root'
          host: 'local'
          engine: 'mariadb'
        .should.throw
          code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
          message: [
            'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
            'Missing required argument: "admin_password"'
          ].join ' '
        
        () -> command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'mariadb'
        .should.throw
          code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
          message: [
            'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS:'
            'Missing required argument: "host"'
          ].join ' '
      
        () -> command
          admin_password: 'rootme'
          engine: 'mariadb'
        .should.throw
          code: 'NIKITA_DB_UTILS_REQUIRED_ARGUMENTS'
          message: new RegExp 'Missing required argument:'
      
    describe 'using engine: mariadb', ->
      
      it 'default values', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'mariadb'
          host: 'localhost'
        .should.equal 'mysql -hlocalhost -P3306 -uroot -p\'rootme\''
      
      it 'user values', ->
        command
          admin_password: 'password'
          admin_username: 'test_user'
          engine: 'mariadb'
          host: 'mariadb'
          port: 1729
        .should.equal 'mysql -hmariadb -P1729 -utest_user -p\'password\''
    
      it 'command option', ->
        command
          admin_password: 'password'
          admin_username: 'test_user'
          engine: 'mariadb'
          host: 'mariadb'
          port: 1729
          command: '''
          show databases;
          '''
        .should.equal 'mysql -hmariadb -P1729 -utest_user -p\'password\' -e "show databases;"'
        
    describe 'using engine: postgresql', ->
      
      it 'default values', ->
        command
          admin_password: 'rootme'
          admin_username: 'root'
          engine: 'postgresql'
          host: 'localhost'
        .should.equal 'PGPASSWORD=rootme psql -h localhost -p 5432 -U root -tAq'
      
      it 'user values', ->
        command
          admin_password: 'password'
          admin_username: 'test_user'
          engine: 'postgresql'
          host: 'postgresql'
          port: 1729
        .should.equal 'PGPASSWORD=password psql -h postgresql -p 1729 -U test_user -tAq'
      
      it 'command option', ->
        command
          admin_password: 'password'
          admin_username: 'test_user'
          engine: 'postgresql'
          host: 'postgresql'
          port: 1729
          command: '''
          show databases;
          '''
        .should.equal 'PGPASSWORD=password psql -h postgresql -p 1729 -U test_user -tAq -c "show databases;"'
