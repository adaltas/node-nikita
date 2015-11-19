
mecano = require '../../src'

describe 'api conditions', ->
  
  it 'dont pass conditions to children', (next) ->
    mecano
    .call
      if: -> true
      unless: -> false
      handler: (options) ->
        (options.if is undefined).should.be.true()
        (options.unless is undefined).should.be.true()
    .then next
