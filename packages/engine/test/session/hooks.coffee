
nikita = require '../../src'

# Test the construction of the session namespace stored in state

describe 'namespace', ->

  describe 'nikita:registry:action:register', ->
    
    it 'alter action - sync', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'nikita:registry:action:register': ({action}, handler)->
            action.options.key = 'new value'
            handler
        context.registry.register
          options:
            namespace: ['an', 'action']
            action:
              key: 'value'
              handler: (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'

    it 'alter action - async', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'nikita:registry:action:register': ({action}, handler)->
            new Promise (accept, reject) ->
              setImmediate ->
                action.options.key = 'new value'
                accept handler
        context.registry.register
          options:
            namespace: ['an', 'action']
            action:
              key: 'value'
              handler: (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'
            
    it 'handler is undefined', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'nikita:registry:action:register': ({action}, handler)->
            (handler is undefined).should.be.ok()
            handler
        context.registry.register
          options:
            namespace: ['an', 'action']
            action: {}

  describe 'nikita:session:handler:call', ->
    
    it 'alter action - async', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'nikita:session:handler:call': ({action, context}, handler) ->
            new Promise (accept, reject) ->
              setImmediate ->
                accept ({action, context}) ->
                  action.options.new_key = 'new value'
                  handler.call context, action: action, context: context
        context.registry.register
          options:
            namespace: ['an', 'action']
            action:
              key: 'value'
              handler: ({options}) -> options
        context.an.action().should.be.finally.eql
          key: 'value'
          new_key: 'new value'
