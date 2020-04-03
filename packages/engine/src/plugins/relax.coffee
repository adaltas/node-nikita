
{merge} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  'nikita:session:normalize': (action) ->
    # Move property from action to metadata
    if action.hasOwnProperty 'relax'
      action.metadata.relax = action.relax
      delete action.relax
  'nikita:session:action': (action) ->
    action.metadata.relax ?= false
    unless typeof action.metadata.relax is 'boolean'
      throw error 'METADATA_RELAX_INVALID_VALUE', [
        "option `relax` expect a boolean value,"
        "got #{JSON.stringify action.metadata.relax}."
      ]
  'nikita:session:handler:call': ({action}, handler) ->
    return handler unless action.metadata.relax
    ({action}) ->
      args = arguments
      new Promise (resolve, reject) ->
        try
          prom = handler.apply action.context, args
          if prom and prom.then
            prom
            .then resolve
            .catch (err) ->
              resolve error: err
          else
            prom
        catch err
          resolve error: err
