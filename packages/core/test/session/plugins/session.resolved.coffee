
nikita = require '../../../src'
session = require '../../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.resolved', ->

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
    # Not sure if we really expect 3 to be called before 1 and 2, what's
    # important in the context of this test is how 'end' is called last
    stack.should.eql [
      '3'
      '1'
      '2'
      'end'
    ]
