
{snake_case} = require './string'

module.exports =
  clean: (content, undefinedOnly) ->
    for k, v of content
      if v and typeof v is 'object'
        module.exports.clean v, undefinedOnly
        continue
      delete content[k] if typeof v is 'undefined'
      delete content[k] if not undefinedOnly and v is null
    content
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
