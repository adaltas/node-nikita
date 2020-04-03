
{merge} = require 'mixme'
error = require '../utils/error'

module.exports = ->
  'nikita:session:normalize': (action, handler) ->
    # Move property from action to metadata
    if action.hasOwnProperty 'relax'
      action.metadata.relax = action.relax
      delete action.relax
    handler
  'nikita:session:action': (action) ->
    action.metadata.relax ?= false
    unless typeof action.metadata.relax is 'boolean'
      throw error 'METADATA_RELAX_INVALID_VALUE', [
        "option `relax` expect a boolean value,"
        "got #{JSON.stringify action.metadata.relax}."
      ]
  'nikita:session:handler:call': ({}, handler) ->
    handler
