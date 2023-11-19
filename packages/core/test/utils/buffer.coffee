
import {trim} from '@nikitajs/core/utils/buffer'
import test from '../test.coffee'

describe 'utils.buffer', ->
  return unless test.tags.api
  
  describe 'trim', ->
  
    it 'remove whitespaces', ->
      buf = trim Buffer.from '\nok\n'
      buf.toString().should.eql 'ok'
