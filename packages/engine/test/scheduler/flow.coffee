
nikita = require '../../src'
schedule = require '../../src/schedule'

describe 'scheduler.flow', ->

  it 'throw error and keep going', ->
    stack = []
    scheduler = schedule()
    await scheduler.add -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    try
      await scheduler.add -> new Promise (resolve, reject) ->
        stack.push 2
        reject Error 'OK'
    catch err
    await scheduler.add -> new Promise (resolve) ->
      stack.push 3
      resolve 3
    new Promise (accept, reject) ->
      scheduler.on_end accept, reject
    .should.be.resolved()

  it 'throw error and keep going', ->
    stack = []
    nikita ->
      # The following used to hang the scheduler
      @call (->)
      await new Promise (resolve, reject) ->
        setTimeout resolve, 10
      @call (->)

  it 'status with relax false', ->
    # Note, there was a bug where the last action was executed but the error
    # was swallowed
    nikita ->
      try await @call -> throw Error 'ok'
      catch err
      @call ->
        throw Error 'Catch me'
    .should.be.rejectedWith 'Catch me'
