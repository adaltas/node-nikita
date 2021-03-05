
module.exports = normalize = (action) ->
  # action
  # console.log '>>>>', action
  if Array.isArray action
    return action.map (action) -> normalize action
  # action.metadata ?= {}
  # action.config ?= {}
  # action.hooks ?= {}
  # for property, value of action
  #   continue if property in properties
  #   if /^on_/.test property
  #     action.hooks[property] = value
  #     delete action[property]
  #   else
  #     action.config[property] = value
  #     delete action[property]
  # console.log '<<<<', action
  action

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'config'
  'parent'
  'plugins'
  'registry'
  'run'
  'scheduler'
  'state'
]
