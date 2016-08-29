
db = require '../../src/misc/db'
should = require 'should'
test = require '../test'

describe 'misc.db', ->

  scratch = test.scratch @

  describe 'jdbc', ->

    it 'get default port', ->
      db.jdbc('jdbc:mysql://localhost/my_db').should.eql
        engine: 'mysql',
        addresses: [ { host: 'localhost', port: 3306 } ],
        database: 'my_db'
      db.jdbc('jdbc:postgresql://localhost/my_db').should.eql
        engine: 'postgres',
        addresses: [ { host: 'localhost', port: 5432 } ],
        database: 'my_db'
    
    it 'get database', ->
      db.jdbc('jdbc:mysql://master3.ryba:3306/my_db?a_param=true').database.should.eql 'my_db'
