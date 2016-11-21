
## Register all functions

    load = (middleware) ->
      middleware = handler: middleware unless typeof middleware is 'object' and middleware? and not Array.isArray middleware
      throw Error "Invalid middleware handler: got #{JSON.stringify middleware.handler}" unless typeof middleware.handler in ['function', 'string']
      return middleware unless typeof middleware.handler is 'string'
      middleware.module = middleware.handler
      middleware.handler = if /^mecano\//.test(middleware.handler) then require(".#{middleware.handler.substr(6)}") else require.main.require middleware.handler
      middleware

    registry = (obj) ->

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
