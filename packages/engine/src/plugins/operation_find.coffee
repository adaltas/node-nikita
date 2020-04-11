
error = require '../utils/error'

find = (action, finder) ->
  precious = await finder action, finder
  return precious if precious?
  return undefined unless action.parent
  find action.parent, finder

module.exports = (action) ->
  module: '@nikitajs/engine/src/plugins/operation_find'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        action = handler.apply null, arguments
        return action unless action.metadata.depth is 0
        action.registry.register ['operations', 'find'],
          raw: true
          handler: (action) ->
            if action.config.length is 1
              [finder] = action.config
            else if action.config.length is 2
              [action, finder] = action.config
            else throw error 'OPERATION_FIND_INVALID_ARGUMENT', [
                'action signature is expected to be'
                '`finder` or `action, finder`'
                "got #{JSON.stringify action.config}"
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
            await find action.parent, finder
        action
