
nikita = require '../../src'

# Test the construction of the session namespace stored in state

describe 'namespace', ->

  it 'call registered action', ->
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
    result = await n.action()
    result.should.eql 'action value, depth 1'
    result = await n.an.action()
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
    result = await n.action().action()
    result.should.eql 'action value, depth 1'
    result = await n.an.action().an.action()
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
      nikita ({registry}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
      .an.action.broken()
      throw Error 'CulDeSac'
    catch e
      e.message.should.eql 'nikita(...).an.action.broken is not a function'
