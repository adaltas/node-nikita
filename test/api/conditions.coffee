
nikita = require '../../src'

describe 'api conditions', ->
  
  it 'dont pass conditions to children', ->
    nikita
    .call
      if: -> true
      unless: -> false
      handler: (options) ->
        (options.if is undefined).should.be.true()
        (options.unless is undefined).should.be.true()
    .promise()
