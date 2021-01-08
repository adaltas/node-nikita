
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
    await scheduler.push -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    try
      await scheduler.push -> new Promise (resolve, reject) ->
        stack.push 2
        reject Error 'OK'
    catch err
    await scheduler.push -> new Promise (resolve) ->
      stack.push 3
      resolve 3
    scheduler.should.be.resolved()
    scheduler.then ->
      stack.should.eql [1, 2, 3]

  it 'run asynchornously', ->
    stack = []
    scheduler = schedule()
    scheduler.push ->
      stack.push 2
      new Promise (accept, reject) ->
        stack.push 3
        accept()
    stack.push 1
    scheduler.then ->
      stack.should.eql [1, 2, 3]
