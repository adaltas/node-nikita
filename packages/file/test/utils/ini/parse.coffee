
import {ini} from '@nikitajs/file/utils'
import test from '../../test.coffee'
should.config.checkProtoEql = false

describe 'utils.ini.parse', ->
  return unless test.tags.api

  it 'parse depth 1', ->
    data = ini.parse """
      key1=value1
      key 2 = value 2
      key 3="value 3"
      """
    should(data).eql
      'key1': 'value1'
      'key 2': 'value 2'
      'key 3': 'value 3'

  it 'sub levels defined in root brackets', ->
    # Ini return objects with null prototypes
    data = ini.parse """
      [level1.level2.level3]
        level4 = value 4
      """
    should(data).eql
      'level1': level2: level3: level4: 'value 4'
