
utils = require '../utils'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/relax'
  hooks:
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'relax'
        action.metadata.relax = action.relax
        delete action.relax
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
        args = arguments
        new Promise (resolve, reject) ->
          try
            prom = handler.apply action.context, args
            # Not, might need to get inspiration from retry to
            # handle the returned promise
            prom
            .then resolve
            .catch (err) ->
              if typeof action.metadata.relax is 'boolean' or
              err.code in action.metadata.relax or
              action.metadata.relax.some((v) -> err.code.match v)
                resolve error: err
              reject err
          catch err
            resolve error: err
