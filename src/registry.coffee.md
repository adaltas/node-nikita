
## Register all functions

    module.exports = {}

    Object.defineProperty module.exports, 'get', 
      configurable: true
      enumerable: false
      get: -> (name) ->
        name = [name] if typeof name is 'string'
        cnames = module.exports
        for n, i in name
          return null unless cnames[n]
          return cnames[n][''] if cnames[n] and cnames[n][''] and i is name.length - 1
          cnames = cnames[n]
        return null
          
    Object.defineProperty module.exports, 'register', 
      configurable: true
      enumerable: false
      get: -> (name, handler) ->
        name = [name] if typeof name is 'string'
        if Array.isArray name
          cnames = names = module.exports
          for n in [0...name.length - 1]
            n = name[n]
            cnames[n] ?= {}
            cnames = cnames[n]
          cnames[name[name.length-1]] ?= {}
          cnames[name[name.length-1]][''] = handler
          merge module.exports, names
        else
          cleanup = (obj) ->
            for k, v of obj
              v = require.main.require v if typeof v is 'string'
              if v and typeof v is 'object' and not Array.isArray(v) and not v.handler
                cleanup v
              else
                obj[k] = '': v unless k is ''
          cleanup name
          merge module.exports, name
          
    Object.defineProperty module.exports, 'registered', 
      configurable: true
      enumerable: false
      get: -> (name) ->
        name = [name] if typeof name is 'string'
        cnames = module.exports
        for n, i in name
          return false unless cnames[n]
          return true if cnames[n][''] and i is name.length - 1
          cnames = cnames[n]
        return false
            
    Object.defineProperty module.exports, 'unregister', 
      configurable: true
      enumerable: false
      get: -> (name) ->
        name = [name] if typeof name is 'string'
        cnames = module.exports
        for n, i in name
          delete cnames[n] if i is name.length - 1
          cnames = cnames[n]
          return unless cnames
        
## Dependencies

    {merge} = require './misc'
