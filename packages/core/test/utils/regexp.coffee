
regexp = require '../../src/utils/regexp'

describe 'utils.regexp', ->
  
  it 'is', ->
    regexp.is /.*/
    .should.be.true()
    regexp.is {}
    .should.be.false()

  it 'escape', ->
    regexp.escape '/.*/'
    .should.eql '/\\.\\*/'
