
import { escape } from '@nikitajs/db/utils/db'

describe 'db.utils.escape', ->
  
  it 'backslashes', ->
    escape('\\').should.eql '\\\\'

  it 'double quotes', ->
    escape('"').should.eql '\\"'

  it 'backslashes and double quotes', ->
    query = 'SELECT * FROM my_db WHERE name = "John\\\'s"'
    expected = 'SELECT * FROM my_db WHERE name = \\"John\\\\\'s\\"'
    escape(query).should.eql expected
    