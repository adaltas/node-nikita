
module.exports = normalize = (action) ->
  if Array.isArray action
    return action.map (action) -> normalize action
  new_action =
    metadata: action.metadata or {}
    options: action.options or {}
    hooks: action.hooks or {}
  if action.namespace
    action.metadata.namespace = action.namespace
    delete action.namespace
  for property, value of action
    if property is 'metadata'
      continue # Already merged before
    else if property is 'options'
      continue # Already merged before
    else if property is 'hooks'
      continue # Already merged before
    else if property in properties
      new_action[property] = value
    else if /^on_/.test property
      new_action.hooks[property] = value
    else
      new_action.options[property] = value
  new_action

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'parent'
  'registry'
  'options'
  'plugins'
  'scheduler'
  'state'
  'run'
]
