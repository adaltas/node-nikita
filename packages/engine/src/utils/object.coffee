
array = require './array'
{snake_case} = require './string'
{is_object_literal} = require 'mixme'

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
  diff: (obj1, obj2, keys) ->
    unless keys
      keys1 = Object.keys obj1
      keys2 = Object.keys obj2
      keys = array.merge keys1, keys2, array.unique keys1
    diff = {}
    for k, v of obj1
      continue unless keys.indexOf(k) >= 0
      continue if obj2[k] is v
      diff[k] = []
      diff[k][0] = v
    for k, v of obj2
      continue unless keys.indexOf(k) >= 0
      continue if obj1[k] is v
      diff[k] ?= []
      diff[k][1] = v
    diff
  # equals: (obj1, obj2, keys) ->
  #   keys1 = Object.keys obj1
  #   keys2 = Object.keys obj2
  #   if keys
  #     keys1 = keys1.filter (k) -> keys.indexOf(k) isnt -1
  #     keys2 = keys2.filter (k) -> keys.indexOf(k) isnt -1
  #   else keys = keys1
  #   return false if keys1.length isnt keys2.length
  #   for k in keys
  #     return false if obj1[k] isnt obj2[k]
  #   return true
  filter: (source, black, white) ->
    black ?= []
    obj = {}
    # If white list, only use the selected list
    # Otherwise clone it all
    for key in (if white? then white else Object.keys(source))
      # unless part of black list
      obj[key] = source[key] if source.hasOwnProperty(key) and not black.includes(key)
    obj
  snake_case: (source) ->
    obj = {}
    for key, value of source
      obj[snake_case key] = value
    obj
