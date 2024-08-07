
import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
import test from '../../test.coffee'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.resolved', ->
  return unless test.tags.api

  it 'test', ->
    stack = []
    n = nikita ({plugins}) ->
      plugins.register
        'hooks':
          'nikita:resolved': ({action, output}) ->
            stack.push 'end'
      await @call ->
        new Promise (resolve) ->
          setTimeout ->
            stack.push '1'
            resolve()
          , 50
      await @call ->
        new Promise (resolve) ->
          setTimeout ->
            stack.push '2'
            resolve()
          , 50
    n.call ->
      stack.push '3'
    await n
    # what's important in the context of this test is how 'end' is called last
    # however, we also indirectly test action in handler being called after external actions
    stack.should.eql [
      '1'
      '2'
      '3'
      'end'
    ]
