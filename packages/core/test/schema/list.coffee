
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'schema.list', ->

  it 'instance', ->
    n = nikita()
    n.schema.add 'test',
      'type': 'object'
      'properties':
        'a_string': type: 'string'
        'an_integer': type: 'integer', minimum: 1
    n.schema.list().should.eql
      'test#':
        type: 'object',
        properties:
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
      'test':
        type: 'object',
        properties:
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
      'test#/properties/a_string':
        type: 'string'
      'test#/properties/an_integer':
        type: 'integer'
        minimum: 1
