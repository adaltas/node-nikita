
{is_object, is_object_literal} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  # Recommand the `raw` option
  # recommand: '@nikitajs/engine/src/plugins/raw'
  'nikita:session:handler:call': ({}, handler) ->
    # return handler
    ({action}) ->
      args = arguments
      new Promise (resolve, reject) ->
        inherit = ->
          resolve status: false
        interpret = (output) ->
          return resolve output if action.metadata.raw_output
          if typeof output is 'boolean'
            resolve status: output
          else if is_object_literal output
            if output.hasOwnProperty 'status'
              output.status = !!output.status
              resolve output
            else
              # inherit()
              resolve output
          else if not output? or is_object output
            # inherit()
            resolve output
          else
            resolve output
            # reject error 'HANDLER_INVALID_OUTPUT', [
            #   'expect a boolean or an object or nothing'
            #   'unless the `raw_output` option is activated,'
            #   "got #{JSON.stringify output}"
            # ]
        try
          result = handler.apply action.context, args
          if result and result.then
            result.then interpret, reject
          else if result and result.catch
            result.catch reject
          else
            interpret result
        catch err
          reject err
          
