
import { jdbc } from '@nikitajs/db/utils/db'
import test from '../test.coffee'

describe 'db.utils.jdbc', ->
  return unless test.tags.api

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
