
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.tools.schema', ->
  return unless tags.api
  
  describe 'usage', ->
    
    it 'expose the `ajv` instance', ->
      nikita ({tools: {schema}}) ->
        schema.ajv.should.be.an.Object()

    it '`add` registers new schemas', ->
      nikita ({tools: {schema}}) ->
        schema.add
          'type': 'object'
          'properties':
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
        , 'test'
        schema.ajv.schemas.test.schema.should.eql
          type: 'object'
          properties:
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
    
    it '`validate` modifies action', ->
      nikita key: 'value', (action) ->
        action.metadata.schema =
          type: 'object'
          properties:
            key: type: 'array', items: type: 'string'
        await action.tools.schema.validate action
        action.config.key.should.eql ['value']

    it '`validate` return error', ->
      nikita key: 'value', (action) ->
        action.metadata.schema =
          type: 'object'
          properties:
            key: type: 'integer'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      
  describe '$ref with `module://` scheme', ->

    it 'invalid ref location', ->
      nikita.call
        an_object: an_integer: 'abc'
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'module://invalid/action'
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_INVALID_MODULE'
        message: [
          'NIKITA_SCHEMA_INVALID_MODULE:'
          'the module location is not resolvable,'
          'module name is "invalid/action".'
        ].join ' '
  
  describe '$ref with `registry://` scheme', ->

    it 'invalid ref location', ->
      nikita.call
        an_object: an_integer: 'abc'
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://invalid/action'
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_UNREGISTERED_ACTION'
        message: [
          'NIKITA_SCHEMA_UNREGISTERED_ACTION:'
          'the action is not registered inside the Nikita registry,'
          'action namespace is "invalid.action".'
        ].join ' '

    it 'valid', ->
      nikita
      .registry.register ['test', 'schema'],
        metadata: schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      # Valid schema
      .call
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        an_object: an_integer: 1234
      , (->)

    it 'invalid ref location', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://invalid/action'
        an_object: an_integer: 'abc'
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_UNREGISTERED_ACTION'
        message: [
          'NIKITA_SCHEMA_UNREGISTERED_ACTION:'
          'the action is not registered inside the Nikita registry,'
          'action namespace is "invalid.action".'
        ].join ' '

    it 'invalid ref definition', ->
      nikita
      .registry.register ['test', 'schema'],
        metadata: schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      .call
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        $handler: (->)
        an_object: an_integer: 'abc'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        'registry://test/schema/properties/an_integer/type config/an_object/an_integer should be integer,'
        'type is "integer".'
      ].join ' '
