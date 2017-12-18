
    module.exports =
      copy: (options, properties) ->
        obj = {}
        for property in properties
          obj[property] = options[property] if options[property] isnt undefined
        obj
      is_object: (obj) ->
        obj and typeof obj is 'object' and not Array.isArray obj

          
