
{Validator} = require 'jsonschema'

module.exports = () ->
  validator = new Validator()
  add: (name, schema) ->
    return unless schema
    validator.addSchema schema, name
  validate: (options, schema) ->
    validator.validate options, schema
  list: () ->
    validator.schemas
