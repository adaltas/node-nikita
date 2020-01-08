
Ajv = require 'ajv'
ajv_keywords = require 'ajv-keywords'


module.exports = () ->
  ajv = new Ajv
    $data: true
    allErrors: true
    useDefaults: true
    # coerceTypes: true
  ajv_keywords ajv
  add: (name, schema) ->
    return unless schema
    ajv.addSchema schema, name
  validate: (data, schema) ->
    validate = ajv.compile schema
    valid = validate data
    if validate.errors
    then validate.errors.map (error) -> Error ajv.errorsText([error])
    else []
  list: () ->
    schemas: ajv._schemas
    refs: ajv._refs
    fragments: ajv._fragments
