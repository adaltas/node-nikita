
session = require '../session'
utils = require '../utils'

module.exports =
  module: '@nikitajs/engine/src/plugins/assertion'
  require: [
    '@nikitajs/engine/src/metadata/raw'
    '@nikitajs/engine/src/metadata/disabled'
  ]
  hooks:
    'nikita:session:normalize': (action, handler) ->
      # Ventilate assertions properties defined at root
      assertions = {}
      for property, value of action
        if /^(assert)($|_[\w_]+$)/.test property
          throw Error 'ASSERTION_DUPLICATED_DECLARATION', [
            "Property #{property} is defined multiple times,"
            'at the root of the action and inside assertions'
          ] if assertions[property]
          value = [value] unless Array.isArray value
          assertions[property] = value
          delete action[property]
      ->
        action = await handler.call null, ...arguments
        action.assertions = assertions
        action
    'nikita:session:result': ({action, error, output}) ->
      final_run = true
      for k, v of action.assertions
        continue unless handlers[k]?
        local_run = await handlers[k].call null, action, error, output
        final_run = false if local_run is false
      throw utils.error 'NIKITA_INVALID_ASSERTION', [
        'action did not validate the assertion'
      ] unless final_run

handlers =
  assert: (action, error, output) ->
    final_run = true
    for assertion in action.assertions.assert
      if typeof assertion is 'function'
        assertion = await session
          hooks:
            on_result: ({action}) -> delete action.parent
          metadata:
            condition: true
            depth: action.metadata.depth
            raw_output: true
            raw_input: true
          parent: action
          handler: assertion
          config: action.config
          error: error
          output: output
      run = switch typeof assertion
        when 'undefined' then false
        when 'boolean' then condition
        when 'number' then !!condition
        when 'string' then !!condition.length
        when 'object'
          if Buffer.isBuffer(condition)
            !!condition.length
          else if condition is null then false
          else !!Object.keys(condition).length
        else
          throw Error 'Value type is not handled'
      final_run = false if run is false
    final_run
  unassert: (action, error, output) ->
    final_run = true
    for assertion in action.assertions.unless
      if typeof assertion is 'function'
        assertion = await session
          hooks:
            on_result: ({action}) -> delete action.parent
          metadata:
            condition: true
            depth: action.metadata.depth
            raw_output: true
          parent: action
          handler: assertion
          config: action.config
      run = switch typeof assertion
        when 'undefined' then true
        when 'boolean' then !assertion
        when 'number' then !condition
        when 'string' then !assertion.length
        when 'object'
          if Buffer.isBuffer assertion then !assertion.length
          else if assertion is null then true
          else !Object.keys(assertion).length
        else
          throw Error 'Value type is not handled'
      final_run = false if run is false
    final_run
