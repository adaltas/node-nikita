
module.exports = ->
  'nikita:session:normalize': (action, handler) ->
    # Move property from action to metadata
    if action.hasOwnProperty 'disabled'
      action.metadata.disabled = action.disabled
      delete action.disabled
    handler
  'nikita:session:action': (action) ->
    action.metadata.disabled ?= false
  'nikita:session:handler:call': ({action}, handler) ->
    if action.metadata.disabled then (->) else handler
