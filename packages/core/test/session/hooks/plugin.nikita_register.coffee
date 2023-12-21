
import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
import test from '../../test.coffee'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.register', ->
  return unless test.tags.api
  
  it 'alter action - sync', ->
    nikita ({plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            action.config?.key = 'new value'
            handler
      await @registry.register ['an', 'action'],
        config: key: 'value'
        handler: (->)
      await @an.action ({config}) ->
        config.key.should.eql 'new value'

  it 'alter action - async', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        hooks:
          'nikita:register': ({action}, handler)->
            new Promise (resolve, reject) ->
              setImmediate ->
                action.config?.key = 'new value'
                resolve handler
      await context.registry.register ['an', 'action'],
        config: key: 'value'
        handler: (->)
      await context.an.action ({config}) ->
        config.key.should.eql 'new value'
          
  it 'handler is undefined', ->
    nikita ({context, plugins, registry}) ->
      plugins.register
        'hooks':
          'nikita:register': ({action}, handler)->
            (handler is undefined).should.be.ok()
            handler
      context.registry.register ['an', 'action'], {}
