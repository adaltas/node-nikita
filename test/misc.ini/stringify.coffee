
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

  it 'handle boolean', ->
    misc.ini.stringify
      user: preference:
        a_string: 'a value'
        a_boolean_true: true
        a_boolean_false: false
    .should.eql """
    [user.preference]
    a_string = a value
    a_boolean_true
    
    """
