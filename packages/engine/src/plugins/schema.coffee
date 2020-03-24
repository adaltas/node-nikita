
error = require '../utils/error'
Ajv = require 'ajv'
ajv_keywords = require 'ajv-keywords'

parse = (uri) ->
  matches = /^(\w+:)\/\/(.*)/.exec uri
  throw error 'SCHEMA_URI_INVALID_PROTOCOL', [
    'uri must start with a valid protocol'
    'such as "module://" or "registry://",'
    "got #{uri}."
  ] unless matches
  protocol: matches[1]
  pathname: matches[2]

module.exports = ({registry}) ->
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
            action = require.main.require uri
            accept action.schema
          when 'registry:'
            module = pathname.split '/'
            action = registry.get module
            accept action.metadata.schema
  ajv_keywords ajv
  schema =
    add: (schema, name) ->
      return unless schema
      ajv.addSchema schema, name
    validate: (data, schema) ->
      validate = await ajv.compileAsync schema
      valid = validate data
      if validate.errors
      then validate.errors.map (error) -> Error ajv.errorsText([error])
      else []
    list: () ->
      schemas: ajv._schemas
      refs: ajv._refs
      fragments: ajv._fragments
  'nikita:session:action:create': ({action}, handler) ->
    action.schema = schema
    handler
  'nikita:session:handler:call': ({action}, handler) ->
    return handler unless action.metadata.schema
    errors = await schema.validate action.options, action.metadata.schema
    if errors.length
      if errors.length is 1
        error = errors[0]
      else
        error = new Error "Invalid Options: got #{errors.length} errors\n#{errors.map((error) -> error.message).join('\n')}"
        error.errors = errors
      error.options = action.options
      error.metadata = action.metadata
      throw error
    handler
  
