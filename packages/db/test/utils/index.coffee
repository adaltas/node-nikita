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
        admin_password: 'rootme'
        admin_username: 'root'
        host: 'local'
        engine: 'invalid_engine'
      .should.throw 'Unsupported engine: "invalid_engine"'
      
    for engine, _ of db then do (engine) ->
      path = if engine in ['mysql', 'mariadb'] then 'mysql' else 'psql'
        
      describe "using engine: #{engine}", ->
        
        it 'set default port engine', ->
          expected = 'mysql -hmariadb -P3306 -uroot -p\'rootme\''
          expected_psql = 'PGPASSWORD=rootme psql -h postgresql -p 5432 -U root -tAq'
          expected = expected_psql if path is 'psql'
          command
            admin_password: 'rootme'
            admin_username: 'root'
            engine: engine
            host: engine
          .should.equal expected
              
        it "default arguments", ->
          expected = [
            "#{path}"
            "-h#{db[engine].host}"
            "-P#{db[engine].port}"
            "-u#{db[engine].admin_username}"
            "-p'#{db[engine].admin_password}'"
          ].join ' '
          expected_psql = [
            "PGPASSWORD=#{db[engine].admin_password}"
            "#{path}"
            "-h #{db[engine].host}"
            "-p #{db[engine].port}"
            "-U #{db[engine].admin_username}"
            "-tAq"
            ].join ' '
          expected = expected_psql if path is 'psql'
          command(db[engine]).should.equal expected
          
        it 'command option', ->
          cmd = '''
          show databases;
          '''
          expected = [
            "#{path}"
            "-h#{db[engine].host}"
            "-P#{db[engine].port}"
            "-u#{db[engine].admin_username}"
            "-p'#{db[engine].admin_password}'"
            "-e \"#{escape cmd}\""
          ].join ' '
          expected_psql = [
            "PGPASSWORD=#{db[engine].admin_password}"
            "#{path}"
            "-h #{db[engine].host}"
            "-p #{db[engine].port}"
            "-U #{db[engine].admin_username}"
            "-tAq"
            "-c \"#{cmd}\""
            ].join ' '
          expected = expected_psql if path is 'psql'
          command
            command: cmd
            db[engine]
          .should.equal expected
