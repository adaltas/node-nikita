
## Register all functions

    load = (middleware) ->
      middleware = handler: middleware unless typeof middleware is 'object' and middleware? and not Array.isArray middleware
      throw Error "Invalid middleware handler: got #{JSON.stringify middleware.handler}" unless typeof middleware.handler in ['function', 'string']
      return middleware unless typeof middleware.handler is 'string'
      middleware.module = middleware.handler
      middleware.handler = if /^mecano\//.test(middleware.handler) then require(".#{middleware.handler.substr(6)}") else require.main.require middleware.handler
      middleware

    registry = (obj) ->

## Get

Retrieve an action by name.

      Object.defineProperty obj, 'get',
        configurable: true
        enumerable: false
        get: -> (name) ->
          return merge {}, obj unless name
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
mecano.register('first_action', 'path/to/action')
mecano.first_action(options);
```

With a namespace and an action path:

```javascript
mecano.register(['second', 'action'], 'path/to/action')
mecano.second.action(options);
```

With an action object:

```javascript
mecano.register('third_action', {
  relax: true,
  handler: function(options){ console.log(options.relax) }
})
mecano.third_action(options);
```

With a namespace and an action object:

```javascript
mecano.register(['fourth', 'action'], {
  relax: true,
  handler: function(options){ console.log(options.relax) }
})
mecano.fourth.action(options);
```

Multiple actions:

```javascript
mecano.register({
  'fifth_action': 'path/to/action'
  'sixth': {
    '': 'path/to/sixth',
    'action': : 'path/to/sixth/actkon'
  }
})
mecano
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
            merge obj, names
          else
            walk = (obj) ->
              for k, v of obj
                if k isnt '' and v and typeof v is 'object' and not Array.isArray(v) and not v.handler
                  walk v
                else
                  v = load v
                  obj[k] = if k is '' then v else '': v
            walk name
            merge obj, name

## Deprecate

`mecano.deprecate(old_function, [new_function], action)`

Deprecate an old or renamed action. Internally, it leverages 
[Node.js `util.deprecate`][deprecate].

For exemple:

```javascript
mecano.deprecate('old_function', 'new_function', -> 'my_function')
mecano.new_function()
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

# Registered

Test if a function is depreated or not.

      Object.defineProperty obj, 'registered',
        configurable: true
        enumerable: false
        get: -> (name) ->
          return true if module.exports isnt obj and module.exports.registered name
          name = [name] if typeof name is 'string'
          cnames = obj
          for n, i in name
            return false unless cnames[n]
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
            return unless cnames

    registry module.exports

    Object.defineProperty module.exports, 'registry',
      configurable: true
      enumerable: false
      get: -> registry

## Dependencies

    {merge} = require './misc'

[deprecate]: https://nodejs.org/api/util.html#util_util_deprecate_function_string
