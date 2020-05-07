
error = require '../utils/error'

find = (action, finder) ->
  precious = await finder action, finder
  return precious if precious?
  return undefined unless action.parent
  find action.parent, finder

validate = (action, args) ->
  if args.length is 1
    [finder] = args
  else if args.length is 2
    [action, finder] = args
  else throw error 'OPERATION_FIND_INVALID_ARGUMENT', [
    'action signature is expected to be'
    '`finder` or `action, finder`'
    "got #{JSON.stringify args}"
  ] unless action
  throw error 'OPERATION_FIND_ACTION_FINDER_REQUIRED', [
    'argument `action` is missing and must be a valid action'
  ] unless action
  throw error 'OPERATION_FIND_FINDER_REQUIRED', [
    'argument `finder` is missing and must be a function'
  ] unless finder
  throw error 'OPERATION_FIND_FINDER_INVALID', [
    'argument `finder` is missing and must be a function'
  ] unless typeof finder is 'function'
  [action, finder]

module.exports = (action) ->
  module: '@nikitajs/engine/src/plugins/operation_find'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        # Handler execution
        action = handler.apply null, arguments
        # Register function
        action.operations ?= {}
        action.operations.find = ->
          [action, finder] = validate action, arguments
          await find action, finder
        # Register action
        action.registry.register ['operations', 'find'],
          metadata: raw: true
          handler: (action) ->
            [action, finder] = validate action, action.args
            await find action.parent, finder
        action
