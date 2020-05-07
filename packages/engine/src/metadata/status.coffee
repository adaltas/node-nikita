
{is_object, is_object_literal} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/status'
  require: '@nikitajs/engine/src/plugins/history'
  hooks:
    # 'nikita:registry:normalize': (action) ->
    #   action.metadata ?= {}
    #   if action.hasOwnProperty 'shy'
    #     action.metadata.shy = action.shy
    #     delete action.shy
    #   action.metadata.shy ?= false
    'nikita:session:normalize': (action, handler) ->
      # Metadata `shy`
      # Move property from action to metadata
      if action.hasOwnProperty 'shy'
        action.metadata.shy = action.shy
        delete action.shy
      action.metadata.shy ?= false
      # Register action
      action.registry.register ['status'],
        metadata: raw: true
        handler: ({parent, args: [position]}) ->
          if typeof position is 'number'
            parent.children.slice(position)[0].output.status
          else unless position?
            parent.children.some (child) -> child.output.status
          else
            throw error 'NIKITA_STATUS_POSITION_INVALID', [
              'argument position must be an integer if defined,'
              "get #{JSON.stringify position}"
            ]
      ->
        # Handler execution
        action = handler.apply null, arguments
        # Register `status` operation
        action.operations ?= {}
        action.operations.status = (index) ->
          # console.log ':call:status:'
          if arguments.length is 0
            action.children.some (sibling) ->
              # console.log sibling.output
              # return false if sibling.metadata.shy
              # sibling.output?.status is true
              not sibling.metadata.shy and sibling.output?.status is true
          else
            l = action.children.length
            i =  if index < 0 then (l + index) else index
            sibling = action.children[i]
            throw Error "Invalid Index #{index}" unless sibling
            sibling.output.status
        action
    'nikita:session:result':
      before: '@nikitajs/engine/src/plugins/history'
      handler: ({action, error, output}) ->
        inherit = (output) ->
          output ?= {}
          output.status = action.children.some (child) ->
            return false if child.metadata.shy
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
      
            
