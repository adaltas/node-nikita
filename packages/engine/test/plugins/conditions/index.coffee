
nikita = require '../../../src'

describe 'plugin.condition', ->

  it 'normalize', ->
    nikita ->
      @call
        if: true
      , ({conditions}) ->
        conditions.if.should.be.eql [true]
