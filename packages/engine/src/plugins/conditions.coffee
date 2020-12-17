
session = require '../session'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/conditions'
  require: [
    '@nikitajs/engine/src/metadata/raw'
    '@nikitajs/engine/src/metadata/disabled'
  ]
  hooks:
    'nikita:session:normalize': (action, handler) ->
      # Ventilate conditions properties defined at root
      conditions = {}
      for property, value of action
        if /^(if|unless)($|_[\w_]+$)/.test property
          throw Error 'CONDITIONS_DUPLICATED_DECLARATION', [
            "Property #{property} is defined multiple times,"
            'at the root of the action and inside conditions'
          ] if conditions[property]
          value = [value] unless Array.isArray value
          conditions[property] = value
          delete action[property]
      ->
        action = await handler.call null, ...arguments
        action.conditions = conditions
        action
    'nikita:session:action':
      before: '@nikitajs/engine/src/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        action.metadata.disabled = true unless final_run

handlers =
  if: (action) ->
    final_run = true
    for condition in action.conditions.if
      run = switch typeof condition
        when 'undefined' then false
        when 'boolean' then condition
        when 'number' then !!condition
        when 'string' then !!condition.length
        when 'object'
          if Buffer.isBuffer(condition)
            !!condition.length
          else if condition is null then false
          else !!Object.keys(condition).length
        when 'function'
          await session null, ({run}) ->
            run
              hooks:
                on_result: ({action}) -> delete action.parent
              metadata:
                condition: true
                depth: action.metadata.depth
                raw_output: true
              parent: action
              handler: condition
              config: action.config
      final_run = false if run is false
    final_run
  unless: (action) ->
    final_run = true
    for condition in action.conditions.unless
      run = switch typeof condition
        when 'undefined' then true
        when 'boolean' then !condition
        when 'number' then !condition
        when 'string' then !condition.length
        when 'object'
          if Buffer.isBuffer condition then !condition.length
          else if condition is null then true
          else !Object.keys(condition).length
        when 'function'
          ! await session null, ({run}) ->
            run
              hooks:
                on_result: ({action}) -> delete action.parent
              metadata:
                condition: true
                depth: action.metadata.depth
                raw_output: true
              parent: action
              handler: condition
              config: action.config
      final_run = false if run is false
    final_run
