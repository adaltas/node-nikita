
{tags} = require '../test'
regexp = require '../../lib/utils/regexp'

describe 'utils.regexp', ->
  return unless tags.api
  
  it 'is', ->
    regexp.is /.*/
    .should.be.true()
    regexp.is {}
    .should.be.false()

  it 'escape', ->
    regexp.escape '/.*/'
    .should.eql '/\\.\\*/'
