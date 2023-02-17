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
