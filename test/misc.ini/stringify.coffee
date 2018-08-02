
misc = require '../../src/misc'
test = require '../test'

describe 'misc.ini stringify', ->

  it 'honors option separator', ->
    misc.ini.stringify
      user: preference: color: 'rouge'
    , separator: ':'
    .should.eql """
    [user.preference]
    color:rouge
    
    """
