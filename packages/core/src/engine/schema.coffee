
Ajv = require 'ajv'

module.exports = () ->
  ajv = new Ajv(allErrors: true)
  add: (name, schema) ->
    return unless schema
    ajv.addSchema schema, name
  validate: (data, schema) ->
    # console.log data, schema
    validate = ajv.compile schema
    valid = validate data
    if validate.errors
    then validate.errors.map (error) -> Error ajv.errorsText([error])
    else []
  list: () ->
    schemas: ajv._schemas
    refs: ajv._refs
    fragments: ajv._fragments
