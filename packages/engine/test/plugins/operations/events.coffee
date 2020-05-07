
nikita = require '../../../src'

describe 'plugins.operations.events', ->
  
  it 'emit events', ->
    nikita ({operations: {events}}) ->
      new Promise (resolve) ->
        events.on 'my_event', (msg) ->
          resolve msg
        events.emit 'my_event', 'getme'
      .should.be.resolvedWith 'getme'
