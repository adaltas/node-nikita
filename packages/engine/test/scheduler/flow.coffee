
nikita = require '../../src'
schedule = require '../../src/schedule'

describe 'scheduler.flow', ->

  it 'throw error and keep going', ->
    stack = []
    nikita ->
      # The following used to hang the scheduler
      @call (->)
      await new Promise (resolve, reject) ->
        setTimeout resolve, 10
      @call (->)
