
utils = require '../utils'

module.exports =
  name: '@nikitajs/core/src/metadata/relax'
  hooks:
    'nikita:session:action': (action, handler) ->
      action.metadata.relax ?= false
      if typeof action.metadata.relax is 'string' or
      action.metadata.relax instanceof RegExp
        action.metadata.relax = [action.metadata.relax]
      unless typeof action.metadata.relax is 'boolean' or
      action.metadata.relax instanceof Array
        throw utils.error 'METADATA_RELAX_INVALID_VALUE', [
          "configuration `relax` expects a boolean, string, array or regexp",
          "value, got #{JSON.stringify action.metadata.relax}."
        ]
      return handler unless action.metadata.relax
      (action) ->
        try
          result = await handler.call null, action
          return result
        catch err
          if action.metadata.relax is true or
            action.metadata.relax.includes(err.code) or
            action.metadata.relax.some((v) -> err.code.match v)
          then return error: err
          else throw err
