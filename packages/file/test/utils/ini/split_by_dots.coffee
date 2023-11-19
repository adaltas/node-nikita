
import {ini} from '@nikitajs/file/utils'
import test from '../../test.coffee'
should.config.checkProtoEql = false

describe 'utils.ini.split_by_dots', ->
  return unless test.tags.api

  it 'several dot', ->
    splits = ini.split_by_dots('a.bb.ddd').should.eql [
      'a', 'bb', 'ddd'
    ]

  it 'consecutive dots', ->
    splits = ini.split_by_dots('a..b').should.eql [
      'a', '', 'b'
    ]

  it 'trailing dots', ->
    splits = ini.split_by_dots('a.b.').should.eql [
      'a', 'b', ''
    ]

  it 'escape dots', ->
    splits = ini.split_by_dots('\\.a\\.b\\.').should.eql [
      '.a.b.'
    ]

  it 'internal escape sequence', ->
    splits = ini.split_by_dots('a.\\1.1.b').should.eql [
      'a', '\\1', '1', 'b'
    ]
