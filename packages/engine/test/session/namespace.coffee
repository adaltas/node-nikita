
nikita = require '../../src'

# Test the construction of the session namespace stored in state

describe 'namespace', ->

  it 'call registered action', ->
    nikita ({registry}) ->
      registry.register
        'action':
          '': handler: ({metadata}) ->
            @an.action()
            "action value, depth #{metadata.depth}"
        'an':
          'action':
            '': handler: ({metadata}) ->
              "an.action value, depth #{metadata.depth}"
      result = await @action()
      result.should.eql 'action value, depth 1'
      result = await @an.action()
      result.should.eql 'an.action value, depth 1'

  it 'chain calls', ->
    n = nikita ({registry}) ->
      registry.register
        'action':
          '': handler: ({metadata}) ->
            @an.action()
            "action value, depth #{metadata.depth}"
        'an':
          'action':
            '': handler: ({metadata}) ->
              "an.action value, depth #{metadata.depth}"
      result = await @action().action()
      result.should.eql 'action value, depth 1'
      result = await @an.action().an.action()
      result.should.eql 'an.action value, depth 1'

  it 'call unregisted action', ->
    try
      nikita().an()
    catch e
      e.message.should.eql 'nikita(...).an is not a function'

  it 'chain action after unregisted action', ->
    try
      nikita().invalid.action.broken()
    catch e
      e.message.should.eql 'Cannot read property \'action\' of undefined'

  it 'call unregisted action withing registered namespace', ->
    try
      await nikita ({registry, context}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
        context.an.action.broken()
        throw Error 'CulDeSac'
    catch e
      e.message.should.eql 'context.an.action.broken is not a function'

  it.skip 'call unregisted action withing registered namespace', ->
    # No longer working now that inner handler is run asynchronuously
    try
      nikita ({registry}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
      .an.action.broken()
      throw Error 'CulDeSac'
    catch e
      e.message.should.eql 'nikita(...).an.action.broken is not a function'
