
module.exports = normalize = (action) ->
  if Array.isArray action
    return action.map (action) -> normalize action
  action.metadata ?= {}
  action.options ?= {}
  action.hooks ?= {}
  if action.namespace
    action.metadata.namespace = action.namespace
    delete action.namespace
  for property, value of action
    continue if property in properties
    if /^on_/.test property
      action.hooks[property] = value
      delete action[property]
    else
      action.options[property] = value
      delete action[property]
  action

properties = [
  'children'
  'context'
  'handler'
  'hooks'
  'metadata'
  'options'
  'parent'
  'plugins'
  'registry'
  'run'
  'scheduler'
  'sibling'
  'state'
]
