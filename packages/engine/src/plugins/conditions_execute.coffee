
session = require '../session'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/conditions_execute'
  require: [
    '@nikitajs/engine/src/plugins/conditions'
  ]
  hooks:
    'nikita:session:action':
      after: '@nikitajs/engine/src/plugins/conditions'
      before: '@nikitajs/engine/src/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        if not final_run
          action.metadata.disabled = true
        action

handlers =
  if_execute: (action, value) ->
    final_run = true
    for condition in action.conditions.if_execute
      try await session null, ({run}) ->
        {status} = await run
          hooks:
            on_result: ({action}) -> delete action.parent
          metadata:
            condition: true
            depth: action.metadata.depth
          parent: action
          namespace: ['execute']
        , condition
        final_run = false unless status
      catch err
        code_skipped = condition.code_skipped or condition.config?.code_skipped
        throw err if code_skipped and parseInt(code_skipped, 10) isnt err.exit_code
        final_run = false
    final_run
  unless_execute: (action) ->
    final_run = true
    for condition in action.conditions.unless_execute
      try await session null, ({run}) ->
        {status} = await run
          hooks:
            on_result: ({action}) -> delete action.parent
          metadata:
            condition: true
            depth: action.metadata.depth
          parent: action
          namespace: ['execute']
        , condition
        final_run = false if status
      catch err
        code_skipped = condition.code_skipped or condition.config?.code_skipped
        throw err if code_skipped and parseInt(code_skipped, 10) isnt err.exit_code
    final_run
