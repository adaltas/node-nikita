
nikita = require '../../../src'

describe 'plugins.metadata.templated', ->
  
  it 'default', ->
    nikita.call ({metadata: {templated}}) ->
      templated.should.be.true()

  it 'when `false`', ->
    nikita.call
      templated: false
    , ({metadata: {templated}}) ->
      templated.should.be.false()
