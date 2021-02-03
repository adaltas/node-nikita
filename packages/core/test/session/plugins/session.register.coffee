
nikita = require '../../../src'
session = require '../../../src/session'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.register', ->
  
  it 'alter action - sync', ->
    nikita ({plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            action.key = 'new value'
            handler
      @registry.register ['an', 'action'],
        key: 'value'
        handler: (->)
      @an.action ({config}) ->
        config.key.should.eql 'new value'

  it 'alter action - async', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        hooks:
          'nikita:register': ({action}, handler)->
            new Promise (resolve, reject) ->
              setImmediate ->
                action.key = 'new value'
                resolve handler
      context.registry.register ['an', 'action'],
        key: 'value'
        handler: (->)
      context.an.action ({config}) ->
        config.key.should.eql 'new value'
          
  it 'handler is undefined', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            (handler is undefined).should.be.ok()
            handler
      context.registry.register ['an', 'action'], {}
