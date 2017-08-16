
nikita = require '../../src'

describe 'api conditions', ->
  
  it 'pass options as first argument', ->
    nikita
    .call
      if: (options) ->
        options.an_options.should.eql 'a value'
      unless: (options) ->
        options.an_options.should.eql 'a value'
      an_options: 'a value'
      handler: (->)
    .promise()
      
  it 'dont pass conditions to children', ->
    nikita
    .call
      if: -> true
      unless: -> false
      handler: (options) ->
        (options.if is undefined).should.be.true()
        (options.unless is undefined).should.be.true()
    .promise()
