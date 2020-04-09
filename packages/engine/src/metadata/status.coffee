
{is_object, is_object_literal} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  name: 'metadata_status'
  hooks:
    # require '@nikitajs/engine/plugins/history'
    'nikita:session:result': ({}, handler) ->
      ({action, error, output}) ->
        inherit = (output = {})->
          output.status = action.children.some (child) ->
            child.output?.status is true
          output
        if not error and not action.metadata.raw_output
          arguments[0].output =
            if typeof output is 'boolean'
              status: output
            else if is_object_literal output
              if output.hasOwnProperty 'status'
                output.status = !!output.status
                output
              else
                inherit output
            else if not output?
              inherit output
            else if is_object output
              output
            else if Array.isArray(output) or typeof output in ['string', 'number']
              output
            else
              throw error 'HANDLER_INVALID_OUTPUT', [
                'expect a boolean or an object or nothing'
                'unless the `raw_output` configuration is activated,'
                "got #{JSON.stringify output}"
              ]
        handler.apply null, arguments
      
            
