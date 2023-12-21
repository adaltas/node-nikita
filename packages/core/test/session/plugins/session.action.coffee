
import nikita from '@nikitajs/core'
import session from '@nikitajs/core/session'
import test from '../../test.coffee'

# Test the construction of the session namespace stored in state

describe 'session.plugins.session.action', ->
  return unless test.tags.api
  
  describe 'runtime', ->
  
    it 'alter action - async', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              new Promise (resolve, reject) ->
                setImmediate ->
                  resolve (action) ->
                    action.config.new_key = 'new value'
                    handler.call action.context, action
        await context.registry.register ['an', 'action'],
          config: key: 'value'
          handler: ({config}) -> config
        await context.an.action().should.be.finally.containEql
          key: 'value'
          new_key: 'new value'
          $status: false
        
    it 'plugin return a promise, ensure child is executed', ->
      session ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              await new Promise (resolve) -> setImmediate resolve
              handler
        @call name: 'parent', ->
          @call name: 'child', ->
            'ok'
      .should.be.resolvedWith 'ok'
  
  describe 'errors', ->
          
    it 'throw in current context', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              if action.metadata.namespace.join('.') is 'an.action'
              then throw Error 'Catch me'
              else handler
        await context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        await context
        .an.action()
        .should.be.rejectedWith 'Catch me'
          
    it 'thrown parent session', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              if action.metadata.namespace.join('.') is 'an.action'
              then throw Error 'Catch me'
              else handler
        await context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        await context
        .an.action()
      .should.be.rejectedWith 'Catch me'
          
    it 'promise in current context', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              new Promise (resolve, reject) ->
                if action.metadata.namespace.join('.') is 'an.action'
                then reject Error 'Catch me'
                else resolve handler
        await context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        await context
        .an.action()
        .should.be.rejectedWith 'Catch me'
        
    it 'promise in parent session', ->
      nikita ({context, plugins, registry}) ->
        plugins.register
          'hooks':
            'nikita:action': (action, handler) ->
              new Promise (resolve, reject) ->
                if action.metadata.namespace.join('.') is 'an.action'
                then reject Error 'Catch me'
                else resolve handler
        await context.registry.register ['an', 'action'],
          handler: -> throw Error 'You are not invited'
        await context
        .an.action()
      .should.be.rejectedWith 'Catch me'
