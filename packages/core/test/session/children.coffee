
import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
import test from '../test.coffee'

describe 'session.children', ->
  return unless test.tags.api

  it 'in with plugin', ->
    # No external action but we use it as a reference
    stack = []
    await nikita
      $hooks: on_action: (action)->
        new Promise (resolve) ->
          setTimeout ->
            stack.push 'plugin'
            resolve()
          , 100
    , ->
      await @call ({metadata}) ->
        stack.push metadata.position.join ':'
      await @call ({metadata}) ->
        stack.push metadata.position.join ':'
    stack.should.eql ['plugin', '0:0', '0:1']
        
  it 'out', ->
    stack = []
    await nikita
      key: 'value'
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    stack.should.eql ['0:0', '0:1']
  
  it 'out with plugin', ->
    stack = []
    await nikita
      $hooks: on_action: (action)->
        new Promise (resolve) ->
          setTimeout ->
            stack.push 'plugin'
            resolve()
          , 100
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    stack.should.eql ['plugin', '0:0', '0:1']

  it 'in and out after plugin', ->
    stack = []
    await nikita
      $hooks: on_action: (action) ->
        new Promise (resolve) ->
          setTimeout ->
            stack.push 'plugin'
            resolve()
          , 100
    , ({metadata}) ->
      @call ({metadata}) ->
        new Promise (resolve) ->
          setTimeout ->
            stack.push metadata.position.join ':'
            resolve()
          , 100
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    .call ({metadata}) ->
      stack.push metadata.position.join ':'
    stack.should.eql ['plugin', '0:0', '0:1', '0:2']
  
