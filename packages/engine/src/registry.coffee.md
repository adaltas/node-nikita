
# Registry

Management facility to register and unregister actions.

## Register all functions

    load = (namespace) ->
      throw Error "Invalid Argument: namespace must be a string, got #{namespace.toString()}" unless typeof namespace is 'string'
      # middleware = handler: middleware unless typeof middleware is 'object' and middleware? and not Array.isArray middleware
      # throw Error "Invalid middleware handler: got #{JSON.stringify middleware.handler}" unless typeof middleware.handler in ['function', 'string']
      # return middleware unless typeof middleware.handler is 'string'
      # middleware.module = handler
      action = require.main.require namespace
      if typeof action is 'function'
        action = handler: action
      action.module = middleware.module
      action

    create = ({chain, on_register, parent} = {}) ->
      store = {}
      obj = {}

## Get

Retrieve an action by name.

Options include:

* `flatten`
* `deprecate`

      obj.get = (name, options) ->
        if arguments.length is 1 and is_object arguments[0]
          options = name
          name = null
        options ?= {}
        unless name
          # Flatten result
          if options.flatten
            actions = []
            walk = (store, keys) ->
              for k, v of store
                if k is ''
                  continue if v.deprecate and not options.deprecate
                  # flatstore[keys.join '.'] = merge v
                  v.action = keys
                  actions.push merge v
                else
                  walk v, [keys..., k]
            walk store, []
            return actions
          # Tree result
          else
            walk = (store, keys) ->
              res = {}
              for k, v of store
                if k is ''
                  continue if v.deprecate and not options.deprecate
                  res[k] = merge v
                else
                  v = walk v, [keys..., k]
                  res[k] = v unless Object.values(v).length is 0
              res
            return walk store, []
        name = [name] if typeof name is 'string'
        cnames = store
        for n, i in name.concat ['']
          continue unless cnames[n]
          return cnames[n] if cnames[n] and i is name.length
          cnames = cnames[n]
        if parent
        then parent.get name, options
        else null

## Register

Register new actions.

With an action path:

```javascript
nikita.register('first_action', 'path/to/action')
nikita.first_action(options);
```

With a namespace and an action path:

```javascript
nikita.register(['second', 'action'], 'path/to/action')
nikita.second.action(options);
```

With an action object:

```javascript
nikita.register('third_action', {
  relax: true,
  handler: function(options){ console.info(options.relax) }
})
nikita.third_action(options);
```

With a namespace and an action object:

```javascript
nikita.register(['fourth', 'action'], {
  relax: true,
  handler: function(options){ console.info(options.relax) }
})
nikita.fourth.action(options);
```

Multiple actions:

```javascript
nikita.register({
  'fifth_action': 'path/to/action'
  'sixth': {
    '': 'path/to/sixth',
    'action': : 'path/to/sixth/actkon'
  }
})
nikita
.fifth_action(options);
.sixth(options);
.sixth.action(options);
```

      obj.register = (name, handler) ->
        name = [name] if typeof name is 'string'
        if Array.isArray name
          return chain if handler is undefined
          if typeof handler is 'string'
            handler = load handler
          if typeof handler is 'function'
            handler = handler: handler
          child_store = store
          for i in [0...name.length]
            property = name[i]
            child_store[property] ?= {}
            child_store = child_store[property]
          child_store[''] = handler
          if on_register
            on_register name, handler
        else
          walk = (namespace, store) ->
            for k, v of store
              if k isnt '' and v and typeof v is 'object' and not Array.isArray(v) and not v.handler
                namespace.push k
                walk namespace, v
              else
                if typeof v.handler is 'string'
                  v = merge v, load v
                if v.handler? and typeof v.handler isnt 'function'
                  throw Error "Invalid Handler: expect a function, got #{v.handler}"
                namespace.push k
                store[k] = if k is '' then v else '': v
                if on_register
                  on_register namespace, v
          walk [], name
          mutate store, name
        chain

## Deprecate

`nikita.deprecate(old_function, [new_function], action)`

Deprecate an old or renamed action. Internally, it leverages 
[Node.js `util.deprecate`][deprecate].

For example:

```javascript
nikita.deprecate('old_function', 'new_function', -> 'my_function')
nikita.new_function()
# Print
# (node:75923) DeprecationWarning: old_function is deprecated, use new_function
```

      obj.deprecate = (old_name, new_name, handler) ->
        if arguments.length is 2
          handler = new_name
          new_name = null
        action = load handler
        action.deprecate = new_name
        action.deprecate ?= action.module if typeof action.module is 'string'
        action.deprecate ?= true
        obj.register old_name, action
        chain

# Registered

Test if a function is registered or not.

Options:

* `local` (boolean)   
  Search action in the parent registries.
* `partial` (boolean)   
  Return true if name match a namespace and not a leaf action.

      obj.registered = (name, options = {}) ->
        name = [name] if typeof name is 'string'
        return true if not options.local and parent and parent.registered name, options
        cnames = store
        for n, i in name
          return false if not cnames[n]? or not cnames.propertyIsEnumerable(n)
          return true if options.partial and cnames[n] and i is name.length - 1
          return true if cnames[n][''] and i is name.length - 1
          cnames = cnames[n]
        false

## Unregister

Remove an action from registry.

      obj.unregister = (name) ->
        name = [name] if typeof name is 'string'
        cnames = store
        for n, i in name
          delete cnames[n] if i is name.length - 1
          cnames = cnames[n]
          return chain unless cnames
        chain
      
      obj

    module.exports = create()

    module.exports.create = create

## Dependencies

    {is_object, merge, mutate} = require 'mixme'

[deprecate]: https://nodejs.org/api/util.html#util_util_deprecate_function_string
