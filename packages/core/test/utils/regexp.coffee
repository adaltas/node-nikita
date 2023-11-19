
import regexp from '@nikitajs/core/utils/regexp'
import test from '../test.coffee'

describe 'utils.regexp', ->
  return unless test.tags.api
  
  it 'is', ->
    regexp.is /.*/
    .should.be.true()
    regexp.is {}
    .should.be.false()

  it 'escape', ->
    regexp.escape '/.*/'
    .should.eql '/\\.\\*/'
