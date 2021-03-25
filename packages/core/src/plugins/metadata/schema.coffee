###
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
###

utils = require '../../utils'
{is_object_literal} = require 'mixme'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/schema'
  require: [
    '@nikitajs/core/src/plugins/tools/schema'
  ]
  hooks:
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/global'
        # '@nikitajs/core/src/plugins/metadata/disabled'
      ]
      handler: (action, handler) ->
        if action.metadata.schema? and not is_object_literal action.metadata.schema
          throw utils.error 'METADATA_SCHEMA_INVALID_VALUE', [
            "option `schema` expect an object literal value,"
            "got #{JSON.stringify action.metadata.schema} in"
            if action.metadata.namespace.length
            then "action `#{action.metadata.namespace.join('.')}`."
            else "root action."
          ]
        return handler unless action.metadata.schema
        err = await action.tools.schema.validate action
        ->
          throw err if err
          handler.apply null, arguments
  
