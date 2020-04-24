
{snake_case} = require './string'

module.exports =
  copy: (source, properties) ->
    obj = {}
    for property in properties
      obj[property] = source[property] if source[property] isnt undefined
    obj
  snake_case: (source) ->
    obj = {}
    for key, value of source
      obj[snake_case key] = value
    obj
