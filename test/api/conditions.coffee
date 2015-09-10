
mecano = require '../../src'

describe 'api conditions', ->
  
  it 'dont pass conditions to children', (next) ->
    mecano
    .call
      if: -> true
      not_if: -> false
      handler: (options) ->
        (options.if is undefined).should.be.true()
        (options.not_if is undefined).should.be.true()
    .then next
