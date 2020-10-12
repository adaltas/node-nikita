
session = require '../session'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/conditions_execute'
  require: [
    '@nikitajs/engine/src/plugins/conditions'
  ]
  hooks:
    # 'nikita:session:normalize': (action, handler) ->
    #   # Ventilate conditions properties defined at root
    #   conditions = {}
    #   for property, value of action
    #     if /^(if|unless)($|_[\w_]+$)/.test property
    #       throw Error 'CONDITIONS_DUPLICATED_DECLARATION', [
    #         "Property #{property} is defined multiple times,"
    #         'at the root of the action and inside conditions'
    #       ] if conditions[property]
    #       value = [value] unless Array.isArray value
    #       conditions[property] = value
    #       delete action[property]
    #   ->
    #     action = handler.call null, ...arguments
    #     action.conditions[k] = v for k, v of conditions
    #     action
    'nikita:session:action':
      after: '@nikitajs/engine/src/plugins/conditions'
      before: '@nikitajs/engine/src/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        action.metadata.disabled = true unless final_run

handlers =
  if_execute: (action, value) ->
    final_run = true
    for condition in action.conditions.if_execute
      await session null, ({run}) ->
        {status} = await run
          metadata:
            condition: true
            depth: action.metadata.depth
          parent: action
          namespace: ['execute']
          code_skipped: 1
        , condition
        final_run = false unless status
    final_run
  unless_execute: (action) ->
    final_run = true
    for condition in action.conditions.unless_execute
      await session null, ({run}) ->
        {status} = await run
          metadata:
            condition: true
            depth: action.metadata.depth
          parent: action
          namespace: ['execute']
          code_skipped: 1
        , condition
        final_run = false if status
      final_run = false
    final_run
