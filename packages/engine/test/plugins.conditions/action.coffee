
nikita = require '../../src'

describe 'plugin.condition.action', ->

  it 'function', ->
    nikita ({schema}) ->
      output = await @call
        if: true
        handler: ->
          'called'
      output.should.eql 'called'
