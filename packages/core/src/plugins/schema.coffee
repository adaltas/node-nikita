###
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
###

error = require '../utils/error'
Ajv = require('ajv').default
ajv_keywords = require 'ajv-keywords'
ajv_formats = require "ajv-formats"
{is_object_literal} = require 'mixme'

parse = (uri) ->
  matches = /^(\w+:)\/\/(.*)/.exec uri
  throw error 'SCHEMA_URI_INVALID_PROTOCOL', [
    'uri must start with a valid protocol'
    'such as "module://" or "registry://",'
    "got #{uri}."
  ] unless matches
  protocol: matches[1]
  pathname: matches[2]

module.exports =
  name: '@nikitajs/core/src/plugins/schema'
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
            # coerceTypes: true
            loadSchema: (uri) ->
              new Promise (accept, reject) ->
                {protocol, pathname} = parse uri
                switch protocol
                  when 'module:'
                    try
                      action = require.main.require pathname
                      accept action.metadata.schema
                    catch err
                      reject error 'NIKITA_SCHEMA_INVALID_MODULE', [
                        'the module location is not resolvable,'
                        "module name is #{JSON.stringify pathname}."
                      ]
                  when 'registry:'
                    module = pathname.split '/'
                    action = await action.registry.get module
                    if action
                      accept action.metadata.schema
                    else
                      reject error 'NIKITA_SCHEMA_UNREGISTERED_ACTION', [
                        'the action is not registered inside the Nikita registry,'
                        "action namespace is #{JSON.stringify module.join '.'}."
                      ]
          ajv_keywords ajv
          ajv_formats ajv
          action.tools.schema =
            ajv: ajv
            add: (schema, name) ->
              return unless schema
              ajv.addSchema schema, name
            validate: (action) ->
              validate = await ajv.compileAsync action.metadata.schema
              return if validate action.config
              error 'NIKITA_SCHEMA_VALIDATION_CONFIG', [
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
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/global'
      ]
      handler: (action, handler) ->
        if action.metadata.schema? and not is_object_literal action.metadata.schema
          throw error 'METADATA_SCHEMA_INVALID_VALUE', [
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
  
