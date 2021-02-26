
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.schema', ->
  return unless tags.api

  it 'expose ajv', ->
    nikita ({tools: {schema}}) ->
      schema.ajv.should.be.an.Object()

  it.skip 'validate strict mode', ->
    # Despite strict mode activated in AJV,
    # This generates a log and execute the handler
    # instead of raising an error
    nikita
      $schema:
        type: 'object'
        properties:
          'parent':
            required: ['child']
    , ->
      console.log 'called but why, the doc say the contrary'

  it 'registered inside action', ->
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

  # it 'declaration is valid', ->
  #   TODO: ensure an invalid schema definition error
  #   is catched and handled by nikita

  it 'config is valid', ->
    nikita ->
      {a_string, an_integer} = await @call
        a_string: 'a value'
        an_integer: 1
        $schema:
          type: 'object'
          properties:
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
        handler: ({config}) -> config
      a_string.should.be.a.String()
      an_integer.should.be.a.Number()
  
  describe 'plugins', ->
    
    it ' with `metadata.disabled` as `true`', ->
      # No validation occured when disabled
      nikita
      .call
        $disabled: true
        $schema: 
          type: 'object'
          properties:
            'a_string': type: 'string'
          required: ['a_string']
      , -> throw Error 'KO'
      .should.be.resolved()
        
    it ' with `metadata.disabled` as `false`', ->
      # Validation occured when not disabled
      nikita
      .call
        $disabled: false
        $schema: 
          type: 'object'
          properties:
            'a_string': type: 'string'
          required: ['a_string']
      , -> throw Error 'KO'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
    
    it 'run after the condition plugin', ->
      schema =
        type: 'object'
        properties:
          'a_string': type: 'string'
        required: ['a_string']
      # No validation occured when condition failed
      nikita
      .call
        $schema: schema
        if: false
      , -> throw Error 'KO'
      .should.be.resolved()
      # Validation occured if condition succeed
      nikita
      .call
        $schema: schema
        if: true
      , -> throw Error 'KO'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  describe 'errors', ->

    it 'invalid with one error', ->
      nikita.call
        a_string: 1
        an_integer: 0
        $schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer', 'minimum': 1
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/properties/an_integer/minimum config/an_integer should be >= 1,'
        'comparison is ">=", limit is 1.'
      ].join ' '

    it 'nice message with additionalProperties', ->
      nikita.call
        a_string: 'ok'
        lonely_duck: true
        $schema:
          type: 'object'
          properties:
            'a_string': type: 'string'
          additionalProperties: false
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/additionalProperties config should NOT have additional properties,'
        'additionalProperty is "lonely_duck".'
      ].join ' '
    
    it 'ensure schema is an object in root action', ->
      nikita
        $schema: true
        handler: (->)
      .should.be.rejectedWith [
        'METADATA_SCHEMA_INVALID_VALUE:'
        'option `schema` expect an object literal value,'
        'got true in root action.'
      ].join ' '

    it 'ensure schema is an object in child action', ->
      nikita.call
        $schema: true
        handler: (->)
      .should.be.rejectedWith [
        'METADATA_SCHEMA_INVALID_VALUE:'
        'option `schema` expect an object literal value,'
        'got true in action `call`.'
      ].join ' '
  
  describe '$ref module', ->

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
  
  describe '$ref registry', ->

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
        an_object: an_integer: 1234
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        handler: (->)

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

    it 'invalid ref definition', ->
      nikita
      .registry.register ['test', 'schema'],
        metadata: schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      .call
        an_object: an_integer: 'abc'
        $schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        'registry://test/schema/properties/an_integer/type config/an_object/an_integer should be integer,'
        'type is "integer".'
      ].join ' '
  
  describe 'constructor', ->

    it 'useDefaults', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'a_string':
              type: 'string'
              default: 'a value'
        handler: ({config}) ->
          config.a_string.should.eql 'a value'

    it.skip 'coerceTypes', ->
      # Option is currently disactivated because it is unclear wether we shall
      # accept its rule or create ours. For example, `true` is cast to string `"true"`
      # and string `""` is cast to `null` which might not be what we want.
      nikita.call
        $schema:
          type: 'object'
          properties:
            'int_to_string':
              type: 'string'
            'string_to_boolean':
              type: 'boolean'
        int_to_string: 1234
        string_to_boolean: ''
        handler: ({config}) ->
          config.int_to_string.should.eql '1234'
          config.string_to_boolean.should.be.false()
  
  describe 'ajv-keywords', ->

    it 'instanceof valid', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        config:
          a_regexp: /.*/
        handler: ({config}) ->
          'ok'.should.match config.a_regexp

    it 'instanceof invalid', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        config:
          a_regexp: 'invalid'
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/properties/a_regexp/instanceof config/a_regexp should pass "instanceof" keyword validation.'
      ].join ' '

  describe 'custom keywords', ->

    it 'filemode true with string casted to octal', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'mode':
              type: ['integer', 'string']
              filemode: true
        config:
          mode: '744'
      , ({config}) ->
        config.mode.should.eql 0o0744

    it 'filemode false is invalid', ->
      nikita.call
        $schema:
          type: 'object'
          properties:
            'mode':
              type: ['integer', 'string']
              filemode: false
        config:
          mode: '744'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_INVALID_DEFINITION'
        
