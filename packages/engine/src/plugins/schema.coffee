
error = require '../utils/error'
Ajv = require 'ajv'
ajv_keywords = require 'ajv-keywords'
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

module.exports = (action) ->
  # schema = create(action)
  ajv = new Ajv
    $data: true
    allErrors: true
    useDefaults: true
    # extendRefs: 'ignore'
    extendRefs: true
    # coerceTypes: true
    loadSchema: (uri) ->
      new Promise (accept, reject) ->
        {protocol, pathname} = parse uri
        switch protocol
          when 'module:'
            action = require.main.require pathname
            accept action.schema
          when 'registry:'
            module = pathname.split '/'
            action = await action.registry.get module
            accept action.metadata.schema
  ajv_keywords ajv
  schema =
    add: (schema, name) ->
      return unless schema
      ajv.addSchema schema, name
    validate: (action, schema) ->
      validate = await ajv.compileAsync schema
      return if validate action.config
      error 'NIKITA_SCHEMA_VALIDATION_CONFIG', [
        if validate.errors.length is 1
        then 'one error was found in the configuration of'
        else 'multiple errors where found in the configuration of'
        if action.metadata.namespace.length
        then "action `#{action.metadata.namespace.join('.')}`:"
        else "anonymous action:"
        validate.errors
        .map (err) ->
          msg = err.schemaPath+' '+ajv.errorsText([err]).replace /^data/, 'config'
          msg += (", #{key} is #{JSON.stringify value}" for key, value of err.params).join '' if err.params
          msg
        .sort()
        .join('; ')+'.'
      ]
    list: () ->
      schemas: ajv._schemas
      refs: ajv._refs
      fragments: ajv._fragments
  module: '@nikitajs/engine/src/plugins/schema'
  hooks:
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      if action.hasOwnProperty 'schema'
        action.metadata.schema = action.schema
        delete action.schema
    'nikita:session:normalize': (action) ->
      if action.hasOwnProperty 'schema'
        action.metadata.schema = action.schema
        delete action.schema
    'nikita:session:action':
      after: [
        '@nikitajs/engine/src/metadata/disabled'
        '@nikitajs/engine/src/plugins/conditions'
      ]
      handler: (action, handler) ->
        return handler if action.metadata.disabled
        action.schema = schema
        if action.metadata.schema? and not is_object_literal action.metadata.schema
          throw error 'METADATA_SCHEMA_INVALID_VALUE', [
            "option `schema` expect an object literal value,"
            "got #{JSON.stringify action.metadata.schema}."
          ]
        return handler unless action.metadata.schema
        err = await schema.validate action, action.metadata.schema
        if err then throw err else handler
  
