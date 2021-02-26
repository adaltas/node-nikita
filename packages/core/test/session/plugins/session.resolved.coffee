
{tags} = require '../../test'
nikita = require '../../../src'
session = require '../../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.resolved', ->
  return unless tags.api

  it 'test', ->
    stack = []
    n = nikita ({context, plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:resolved': ({action, output}) ->
            stack.push 'end'
      @call ->
        stack.push '1'
      @call ->
        stack.push '2'
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
