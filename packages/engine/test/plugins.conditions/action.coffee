
nikita = require '../../src'

describe 'plugin.condition.action', ->

  it.skip 'function', ->
    nikita ->
      @call
        if: true
      , ({conditions}) ->
        conditions.if.should.be.True()
