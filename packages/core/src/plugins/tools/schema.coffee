###
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
###

utils = require '../../utils'
Ajv = require('ajv').default
ajv_keywords = require 'ajv-keywords'
ajv_formats = require "ajv-formats"

parse = (uri) ->
  matches = /^(\w+:)\/\/(.*)/.exec uri
  throw utils.error 'SCHEMA_URI_INVALID_PROTOCOL', [
    'uri must start with a valid protocol'
    'such as "module://" or "registry://",'
    "got #{uri}."
  ] unless matches
  protocol: matches[1]
  pathname: matches[2]

module.exports =
  name: '@nikitajs/core/src/plugins/tools/schema'
  hooks:
    'nikita:normalize':
      handler: (action, handler) ->
        ->
          # Handler execution
          action = await handler.apply null, arguments
          action.tools ?= {}
          # Get schema from parent action
          if action.parent?.tools.schema
            action.tools.schema = action.parent.tools.schema
            return action
          # Instantiate a new schema
          ajv = new Ajv
            $data: true
            allErrors: true
            useDefaults: true
            allowUnionTypes: true # eg type: ['boolean', 'integer']
            strict: true
            # extendRefs: true
            coerceTypes: 'array'
            loadSchema: (uri) ->
              new Promise (accept, reject) ->
                {protocol, pathname} = parse uri
                switch protocol
                  when 'module:'
                    try
                      action = require.main.require pathname
                      accept action.metadata.schema
                    catch err
                      reject utils.error 'NIKITA_SCHEMA_INVALID_MODULE', [
                        'the module location is not resolvable,'
                        "module name is #{JSON.stringify pathname}."
                      ]
                  when 'registry:'
                    module = pathname.split '/'
                    action = await action.registry.get module
                    if action
                      accept action.metadata.schema
                    else
                      reject utils.error 'NIKITA_SCHEMA_UNREGISTERED_ACTION', [
                        'the action is not registered inside the Nikita registry,'
                        "action namespace is #{JSON.stringify module.join '.'}."
                      ]
          ajv_keywords ajv
          ajv_formats ajv
          ajv.addKeyword
            keyword: "filemode"
            type: ['integer', 'string']
            compile: (value) ->
              return (data, schema, parentData) ->
                if typeof data is 'string' and /^\d+$/.test data
                  schema.parentData[schema.parentDataProperty] = parseInt data, 8
                true
            metaSchema:
              type: 'boolean'
              enum: [true]
          action.tools.schema =
            ajv: ajv
            add: (schema, name) ->
              return unless schema
              ajv.addSchema schema, name
            validate: (action) ->
              try
                validate = await ajv.compileAsync action.metadata.schema
              catch err
                unless err.code
                  err.code = 'NIKITA_SCHEMA_INVALID_DEFINITION'
                  err.message = "#{err.code}: #{err.message}"
                throw err
              return if validate action.config
              utils.error 'NIKITA_SCHEMA_VALIDATION_CONFIG', [
                if validate.errors.length is 1
                then 'one error was found in the configuration of'
                else 'multiple errors where found in the configuration of'
                if action.metadata.namespace.length
                then "action `#{action.metadata.namespace.join('.')}`:"
                else "root action:"
                validate.errors
                .map (err) ->
                  msg = err.schemaPath+' '+ajv.errorsText([err]).replace /^data/, 'config'
                  msg += (
                    for key, value of err.params
                      continue if key is 'missingProperty'
                      ", #{key} is #{JSON.stringify value}"
                  ).join '' if err.params
                  msg
                .sort()
                .join('; ')+'.'
              ]
          action
