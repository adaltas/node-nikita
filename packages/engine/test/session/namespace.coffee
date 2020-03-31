
nikita = require '../../src'
registry = require '../../src/registry'

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

  it 'chain action after unregisted action', ->
    try
      await nikita().invalid.action.broken()
    catch err
      err.message.should.eql 'No action named "invalid.action.broken"'
  
  describe 'error', ->

    it 'unregisted root action from static', ->
      nikita.invalid()
      .should.be.rejectedWith 'No action named "invalid"'

    it 'unregisted root action from instance', ->
      nikita().invalid()
      .should.be.rejectedWith 'No action named "invalid"'

    it 'unregisted action within a registered namespace outside handler', ->
      # No longer working now that inner handler is run asynchronuously
      nikita ({registry}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
      .an.action.broken()
      .should.be.rejectedWith 'No action named "an.action.broken"'

    it 'unregisted action within a registered namespace inside handler', ->
      # No longer working now that inner handler is run asynchronuously
      nikita ({registry, context}) ->
        registry.register
          'an': 'action':
            '': handler: (->)
        context.an.action.broken()
      .should.be.rejectedWith 'No action named "an.action.broken"'

    it 'unregisted action within a registered static namespace', ->
      # Internally, the proxy for nikita is not the same as for its children
      registry.register ['an', 'action'], (->)
      nikita.an.action.invalid()
      .should.be.rejectedWith 'No action named "an.action.invalid"'
      registry.unregister ['an', 'action']

    it 'parent name not defined child action undefined', ->
      nikita.not.an.action()
      .should.be.rejectedWith 'No action named "not.an.action"'
