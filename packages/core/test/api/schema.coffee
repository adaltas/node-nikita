
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'schema', ->
  
  describe 'list', ->

    it 'instance', ->
      n = nikita()
      n.schema.add
        'type': 'object'
        'properties':
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
      , 'test'
      n.schema.list().schemas.test.schema.should.eql
        type: 'object'
        properties:
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
