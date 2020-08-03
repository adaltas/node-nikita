
module.exports = ->
  module: '@nikitajs/engine/src/metadata/templated'
  hooks:
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'templated'
        action.metadata.templated = action.templated
        delete action.templated
      action.metadata.templated ?= true
