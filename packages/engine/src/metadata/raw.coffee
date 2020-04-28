
module.exports = ->
  module: '@nikitajs/engine/src/metadata/raw'
  hooks:
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      for property in ['raw', 'raw_input', 'raw_output']
        if action.hasOwnProperty property
          action.metadata[property] = action[property]
          delete action[property]
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      for property in ['raw', 'raw_input', 'raw_output']
        if action.hasOwnProperty property
          action.metadata[property] = action[property]
          delete action[property]
    'nikita:session:action': (action) ->
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
