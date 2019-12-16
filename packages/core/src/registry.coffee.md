
# Registry

Management facility to register and unregister actions.

## Register all functions

    load = (middleware) ->
      middleware = handler: middleware unless typeof middleware is 'object' and middleware? and not Array.isArray middleware
      throw Error "Invalid middleware handler: got #{JSON.stringify middleware.handler}" unless typeof middleware.handler in ['function', 'string']
      return middleware unless typeof middleware.handler is 'string'
      middleware.module = middleware.handler
      result = if /^nikita\//.test(middleware.handler) then require(".#{middleware.handler.substr(6)}") else require.main.require middleware.handler
      if typeof result is 'function'
        result = handler: result
        result.module = middleware.module
      result

    registry = (obj, options = {}) ->

## Get

Retrieve an action by name.

Options include: flatten, deprecate

      Object.defineProperty obj, 'get',
        configurable: true
        enumerable: false
        get: -> (name, options) ->
          if arguments.length is 1 and is_object arguments[0]
            options = name
            name = null
          options ?= {}
          unless name
            # Flatten result
            if options.flatten
              flatobj = {}
              walk = (obj, keys) ->
                for k, v of obj
                  if k is ''
                    continue if v.deprecate and not options.deprecate
                    flatobj[keys.join '.'] = merge v
                  else
                    walk v, [keys..., k]
              walk obj, []
              return flatobj
            # Tree result
            else
              walk = (obj, keys) ->
                res = {}
                for k, v of obj
                  if k is ''
                    continue if v.deprecate and not options.deprecate
                    res[k] = merge v
                  else
                    v = walk v, [keys..., k]
                    res[k] = v unless Object.values(v).length is 0
                res
              return walk obj, []
          name = [name] if typeof name is 'string'
          cnames = obj
          for n, i in name
            return null unless cnames[n]
            return cnames[n][''] if cnames[n] and cnames[n][''] and i is name.length - 1
            cnames = cnames[n]
          return null

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
  handler: function(options){ console.log(options.relax) }
})
nikita.third_action(options);
```

With a namespace and an action object:

```javascript
nikita.register(['fourth', 'action'], {
  relax: true,
  handler: function(options){ console.log(options.relax) }
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

      Object.defineProperty obj, 'register',
        configurable: true
        enumerable: false
        get: -> (name, handler) ->
          name = [name] if typeof name is 'string'
          if Array.isArray name
            handler = load handler
            cnames = names = obj
            for n in [0...name.length - 1]
              n = name[n]
              cnames[n] ?= {}
              cnames = cnames[n]
            cnames[name[name.length-1]] ?= {}
            cnames[name[name.length-1]][''] = handler
            if options.on_register
              options.on_register name, handler
            mutate obj, names
          else
            walk = (obj) ->
              for k, v of obj
                if k isnt '' and v and typeof v is 'object' and not Array.isArray(v) and not v.handler
                  walk v
                else
                  v = load v
                  obj[k] = if k is '' then v else '': v
            walk name
            mutate obj, name
          options.chain

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

      Object.defineProperty obj, 'deprecate',
        configurable: true
        enumerable: false
        get: -> (old_name, new_name, handler) ->
          if arguments.length is 2
            handler = new_name
            new_name = null
          handler = load handler
          handler.deprecate = new_name
          handler.deprecate ?= handler.module if typeof handler.module is 'string'
          handler.deprecate ?= true
          obj.register old_name, handler
          options.chain

# Registered

Test if a function is registered or not.

Options:

* `parent` (boolean)   
  Return true if the name match a parent action name.

      Object.defineProperty obj, 'registered',
        configurable: true
        enumerable: false
        get: -> (name, options = {}) ->
          return true if module.exports isnt obj and module.exports.registered name
          name = [name] if typeof name is 'string'
          cnames = obj
          for n, i in name
            return false if not cnames[n]? or not cnames.propertyIsEnumerable(n)
            return true if options.parent and cnames[n] and i is name.length - 1
            return true if cnames[n][''] and i is name.length - 1
            cnames = cnames[n]
          return false

## Unregister

Remove an action from registry.

      Object.defineProperty obj, 'unregister',
        configurable: true
        enumerable: false
        get: -> (name) ->
          name = [name] if typeof name is 'string'
          cnames = obj
          for n, i in name
            delete cnames[n] if i is name.length - 1
            cnames = cnames[n]
            return options.chain unless cnames
          options.chain

    registry module.exports

    Object.defineProperty module.exports, 'registry',
      configurable: true
      enumerable: false
      get: -> registry

## Dependencies

    {merge, mutate} = require 'mixme'
    {is_object} = require './misc/object'

[deprecate]: https://nodejs.org/api/util.html#util_util_deprecate_function_string
