
error = require '../utils/error'

walk = (action, walker) ->
  precious = await walker action, walker
  results = []
  results.push precious unless precious is undefined
  results.push ...(await walk action.parent, walker) if action.parent
  results

validate = (action, args) ->
  if args.length is 1
    [walker] = args
  else if args.length is 2
    [action, walker] = args
  else throw error 'OPERATION_WALK_INVALID_ARGUMENT', [
    'action signature is expected to be'
    '`walker` or `action, walker`'
    "got #{JSON.stringify args}"
  ] unless action
  throw error 'OPERATION_WALK_ACTION_WALKER_REQUIRED', [
    'argument `action` is missing and must be a valid action'
  ] unless action
  throw error 'OPERATION_WALK_WALKER_REQUIRED', [
    'argument `walker` is missing and must be a function'
  ] unless walker
  throw error 'OPERATION_WALK_WALKER_INVALID', [
    'argument `walker` is missing and must be a function'
  ] unless typeof walker is 'function'
  [action, walker]

module.exports = (action) ->
  module: '@nikitajs/engine/src/plugins/operation_walk'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        # Handler execution
        action = handler.apply null, arguments
        # Register function
        action.operations ?= {}
        action.operations.walk = ->
          [action, walker] = validate action, arguments
          await walk action, walker
        # Register action
        action.registry.register ['operations', 'walk'],
          raw: true
          handler: (action) ->
            [action, walker] = validate action, action.args
            await walk action.parent, walker
        action
