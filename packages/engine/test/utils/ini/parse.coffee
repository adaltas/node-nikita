
ini = require '../../../src/utils/ini'
{tags} = require '../../test'

return unless tags.api

describe 'utils.ini.parse', ->

  it 'parse depth 1', ->
    ini.parse """
      key1=value1
      key 2 = value 2
      key 3="value 3"
      """
    .should.eql
      'key1': 'value1'
      'key 2': 'value 2'
      'key 3': 'value 3'

  it 'sub levels defined in root brackets', ->
    ini.parse """
      [level1.level2.level3]
        level4 = value 4
      """
    .should.eql
      'level1': level2: level3: level4: 'value 4'
