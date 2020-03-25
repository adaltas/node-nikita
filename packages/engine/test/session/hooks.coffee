
nikita = require '../../src'

# Test the construction of the session namespace stored in state

describe 'namespace', ->

  describe 'nikita:registry:action:register', ->
    
    it 'sync', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'nikita:registry:action:register': ({action}, handler)->
            action.options.key = 'new value'
            handler
        registry.register ['an', 'action'], key: 'value', (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'

    it.skip 'async', ->
      nikita ({context, plugins, registry}) ->
        await plugins.register
          'nikita:registry:action:register': ({action}, handler)->
            new Promise (accept, reject) ->
              setImmediate ->
                action.options.key = 'new value'
                # accept handler
        registry.register ['an', 'action'], key: 'value', (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'
          
