
nikita = require '../../src'
schedule = require '../../src/schedulers/native'

describe 'scheduler.flow', ->

  it 'throw error and keep going', ->
    # Errors inside action doesn't stop
    # the flow of the parent action,
    # it is the responsibility of the user
    # to wait on the action promise,
    # to catch the error and eventually
    # to halt the flow execution.
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
      scheduler.on_end ->
        stack.should.eql [1, 2, 3]
        accept()
      , reject
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

  it.skip 'should validate a created file', ({ssh}) ->
    try
      output = await nikita  ->
        ouptut = await @call ->
          true
        @call ->
          throw Error 'catchme'
        ouptut
      console.log 'should not get here'
      throw Error 'Oh no!'
    catch err
      err.message.should.eql 'catchme'
      console.log 'should get here', err.message
