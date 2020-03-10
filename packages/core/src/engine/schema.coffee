
Ajv = require 'ajv'
ajv_keywords = require 'ajv-keywords'

module.exports = () ->
  ajv = new Ajv
    $data: true
    allErrors: true
    useDefaults: true
    # extendRefs: 'ignore'
    extendRefs: true
    # coerceTypes: true
    # loadSchema: (uri) ->
    #   new Promise (accept, reject) ->
    #     uri = if /^@nikitajs\/core/.test(middleware.handler)
    #     then require "../#{middleware.handler.substr(14)}"
    #     else require.main.require uri
    #     result = uri
  ajv_keywords ajv
  add: (schema, name) ->
    return unless schema
    ajv.addSchema schema, name
  validate: (data, schema) ->
    # validate = ajv.compileAsync schema
    # valid = await validate data
    validate = ajv.compile schema
    valid = validate data
    if validate.errors
    then validate.errors.map (error) -> Error ajv.errorsText([error])
    else []
  list: () ->
    schemas: ajv._schemas
    refs: ajv._refs
    fragments: ajv._fragments
