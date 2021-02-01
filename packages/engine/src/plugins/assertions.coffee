
session = require '../session'
utils = require '../utils'

module.exports =
  name: '@nikitajs/engine/src/plugins/assertions'
  require: [
    '@nikitajs/engine/src/metadata/raw'
    '@nikitajs/engine/src/metadata/disabled'
  ]
  hooks:
    'nikita:session:normalize': (action, handler) ->
      # Ventilate assertions properties defined at root
      assertions = {}
      for property, value of action
        if /^(un)?assert$/.test property
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
        run = await session
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
        throw Error unless typeof run is 'boolean'
      else
        run = utils.object.match output, assertion
      final_run = false if run is false
    final_run
  unassert: (action, error, output) ->
    final_run = true
    for assertion in action.assertions.unassert
      if typeof assertion is 'function'
        run = await session
          hooks:
            on_result: ({action}) -> delete action.parent
          metadata:
            condition: true
            depth: action.metadata.depth
            raw_output: true
          parent: action
          handler: assertion
          config: action.config
        throw Error unless typeof run is 'boolean'
      else
        run = utils.object.match output, assertion
      final_run = false if run is true
    final_run
