
session = require '../../session'

module.exports =
  name: '@nikitajs/core/src/plugins/conditions/execute'
  require: [
    '@nikitajs/core/src/plugins/conditions'
  ]
  hooks:
    'nikita:action':
      after: '@nikitajs/core/src/plugins/conditions'
      before: '@nikitajs/core/src/plugins/metadata/disabled'
      handler: (action) ->
        final_run = true
        for k, v of action.conditions
          continue unless handlers[k]?
          local_run = await handlers[k].call null, action
          final_run = false if local_run is false
        if not final_run
          action.metadata.disabled = true

handlers =
  if_execute: (action, value) ->
    final_run = true
    for condition in action.conditions.if_execute
      try
        {$status} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        , condition
        final_run = false unless $status
      catch err
        {code} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        , condition
        , ({config}) -> code: config.code
        # If `code.false` is present,
        # use it instead of error to disabled the action
        throw err if code.false.length and not code.false.includes err.exit_code
        final_run = false
    final_run
  unless_execute: (action) ->
    final_run = true
    for condition in action.conditions.unless_execute
      try
        {$status} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        , condition
        final_run = false if $status
      catch err
        {code} = await session
          $bastard: true
          $namespace: ['execute']
          $parent: action
        , condition
        , ({config}) -> code: config.code
        # If `code.false` is present,
        # use it instead of error to to disabled the action
        throw err if code.false.length and not code.false.includes err.exit_code
    final_run
