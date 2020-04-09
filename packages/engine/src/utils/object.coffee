
module.exports =
  copy: (source, properties) ->
    obj = {}
    for property in properties
      obj[property] = source[property] if source[property] isnt undefined
    obj
