
nikita = require '../../src'

# Test the construction of the session namespace stored in state

describe 'session.hooks', ->

  describe 'nikita:registry:action:register', ->
    
    it 'alter action - sync', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:registry:action:register': ({action}, handler)->
              action.key = 'new value'
              handler
        context.registry.register ['an', 'action'],
          key: 'value'
          handler: (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'

    it 'alter action - async', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          hooks:
            'nikita:registry:action:register': ({action}, handler)->
              new Promise (accept, reject) ->
                setImmediate ->
                  action.key = 'new value'
                  accept handler
        context.registry.register ['an', 'action'],
          key: 'value'
          handler: (->)
        context.an.action ({options}) ->
          options.key.should.eql 'new value'
            
    it 'handler is undefined', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:registry:action:register': ({action}, handler)->
              (handler is undefined).should.be.ok()
              handler
        context.registry.register ['an', 'action'], {}

  describe 'nikita:session:action', ->
    
    it 'alter action - async', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:session:action': (action, handler) ->
              new Promise (accept, reject) ->
                setImmediate ->
                  accept (action) ->
                    action.options.new_key = 'new value'
                    handler.call action.context, action
        context.registry.register ['an', 'action'],
          key: 'value'
          handler: ({options}) -> options
        context.an.action().should.be.finally.eql
          key: 'value'
          new_key: 'new value'
          status: false
            
    it 'error throw in current context', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:session:action': (action, handler) ->
              if action.metadata.namespace.join('.') is 'an.action'
              then throw Error 'Catch me'
              else handler
        context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        context
        .an.action()
        .should.be.rejectedWith 'Catch me'
          
    it 'error thrown parent session', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:session:action': (action, handler) ->
              if action.metadata.namespace.join('.') is 'an.action'
              then throw Error 'Catch me'
              else handler
        context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        context
        .an.action()
      .should.be.rejectedWith 'Catch me'
          
    it 'error promise in current context', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:session:action': (action, handler) ->
              new Promise (accept, reject) ->
                if action.metadata.namespace.join('.') is 'an.action'
                then reject Error 'Catch me'
                else accept handler
        context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        context
        .an.action()
        .should.be.rejectedWith 'Catch me'
        
    it 'error promise in parent session', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:session:action': (action, handler) ->
              new Promise (accept, reject) ->
                if action.metadata.namespace.join('.') is 'an.action'
                then reject Error 'Catch me'
                else accept handler
        context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        context
        .an.action()
      .should.be.rejectedWith 'Catch me'
