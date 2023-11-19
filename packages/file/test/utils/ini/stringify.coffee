
import {ini} from '@nikitajs/file/utils'
import test from '../../test.coffee'

describe 'utils.ini.stringify', ->
  return unless test.tags.api

  it 'honors option separator', ->
    ini.stringify
      user: preference: color: 'rouge'
    , separator: ':'
    .should.eql """
    [user.preference]
    color:rouge

    """

  it 'handle boolean', ->
    ini.stringify
      user: preference:
        a_string: 'a value'
        a_boolean_true: true
        a_boolean_false: false
    .should.eql """
    [user.preference]
    a_string = a value
    a_boolean_true

    """

  it 'handle array', ->
    ini.stringify
      user: preference:
        ar_string: ['a', 'b']
        ar_boolean: [true, false, true, false]
    .should.eql """
    [user.preference]
    ar_string[] = a
    ar_string[] = b
    ar_boolean[] = true
    ar_boolean[] = false
    ar_boolean[] = true
    ar_boolean[] = false

    """
