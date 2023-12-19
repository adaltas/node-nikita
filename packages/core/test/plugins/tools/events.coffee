
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.events', ->
  return unless test.tags.api
  
  it 'emit custom events', ->
    nikita ({tools: {events}}) ->
      new Promise (resolve) ->
        events.on 'my_event', (msg) ->
          resolve msg
        events.emit 'my_event', 'getme'
      .should.be.resolvedWith 'getme'
  
  it 'emit registered `nikita:action:start` event', ->
    nikita ({tools: {events}}) ->
      records = []
      listener = (record) -> records.push record
      events.addListener 'nikita:action:start', listener
      await this.call(->)
      events.removeListener 'nikita:action:start', listener
      records.should.match [
        action: metadata: namespace: ['call']
        event: 'nikita:action:start'
      ]
  
  it 'emit registered `nikita:action:end` success event', ->
    nikita ({tools: {events}}) ->
      records = []
      listener = (record) -> records.push record
      events.addListener 'nikita:action:end', listener
      await this.call(-> 'getme')
      events.removeListener 'nikita:action:end', listener
      records.should.match [
        action: metadata: namespace: ['call']
        output: 'getme'
        error: undefined
        event: 'nikita:action:end'
      ]
  
  it 'emit registered `nikita:action:end` error event', ->
    nikita ({tools: {events}}) ->
      records = []
      listener = (record) -> records.push record
      events.addListener 'nikita:action:end', listener
      try
        await this.call(-> throw Error 'getme')
      events.removeListener 'nikita:action:end', listener
      records.should.match [
        action: metadata: namespace: ['call']
        output: undefined
        error: message: 'getme'
        event: 'nikita:action:end'
      ]
  
  it 'emit registered `nikita:resolved` event', ->
    # Event is only throw when the root action succeeds
    records = []
    await nikita ({tools: {events}}) ->
      listener = (record) -> records.push record
      events.addListener 'nikita:resolved', listener
      await this.call(-> 'getme')
    records.should.match [
      action: metadata: namespace: []
      output: 'getme'
      event: 'nikita:resolved'
    ]
  
  it 'emit registered `nikita:rejected` event', ->
    # Event is only throw when the root action fails
    records = []
    try
      await nikita ({tools: {events}}) ->
        listener = (record) -> records.push record
        events.addListener 'nikita:rejected', listener
        await this.call(-> throw Error 'catchme')
    records.should.match [
      action: metadata: namespace: []
      error: message: 'catchme'
      event: 'nikita:rejected'
    ]
