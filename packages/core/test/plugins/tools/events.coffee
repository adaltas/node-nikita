
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.events', ->
  return unless test.tags.api
  
  it 'emit events', ->
    nikita ({tools: {events}}) ->
      new Promise (resolve) ->
        events.on 'my_event', (msg) ->
          resolve msg
        events.emit 'my_event', 'getme'
      .should.be.resolvedWith 'getme'
