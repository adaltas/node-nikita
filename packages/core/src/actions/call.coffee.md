
# `nikita.call`

A generic action to call user defined action. It expects the action as a
parameter. It can be the object representing the action or only the handler
function. Alternatively, a string is interpreted as the path to module which
is then required and executed.

## Passing an action

```js
{key} = await nikita.call({
  config: {
    key: 'value'
  },
  handler: ({config}) => config.key
})
assert(key === 'value')
```

## Passing a function

```js
const key = await nikita.call( () => 'value' )
assert(key === 'value')
```

You can also provide the fuction among other arguments:

```js
const key = await nikita.call( {
  key: 'value'
}, ({config}) => {
  return config.key
})
assert(key === 'value')
```

## Using a module path

```js
const key = await nikita
.fs.base.writeFile({
    content: 'module.exports = ({config}) => "value"',
    target: '/tmp/my_module'
})
.call( '/tmp/my_module' )
assert(key === 'value')
```

## Exports

    module.exports =
      hooks:
        on_action: (action) ->
          return unless typeof action.metadata.argument is 'string'
          mod = action.metadata.argument
          mod = path.resolve process.cwd(), mod if mod.substr(0, 1) is '.'
          mod = require.main.require mod
          on_action = mod.hooks?.on_action
          mod = handler: mod if typeof mod is 'function'
          mutate action, mod, metadata: module: action.metadata.argument
          action = on_action.call null, action if on_action
          action

## Dependencies

    path = require 'path'
    {mutate} = require 'mixme'
