
nikita = require '../../src'

describe 'plugins.schema', ->

  it 'registered inside action', ->
    nikita ({schema}) ->
      schema.add
        'type': 'object'
        'properties':
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
      , 'test'
      schema.list().schemas.test.schema.should.eql
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
        schema:
          type: 'object'
          properties:
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
        handler: ({config}) -> config
      a_string.should.be.a.String()
      an_integer.should.be.a.Number()
    
  it 'doesnt apply when condition is false', ->
    nikita
    .call
      schema:
        type: 'object'
        properties:
          'a_string': type: 'string'
        required: ['a_string']
      if: false
    , -> throw Error 'KO'
    .should.be.resolved()
  
  describe 'errors', ->

    it 'invalid with one error', ->
      nikita.call
        a_string: 1
        an_integer: 0
        schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer', 'minimum': 1
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/properties/an_integer/minimum config.an_integer should be >= 1,'
        'comparison is ">=", limit is 1, exclusive is false.'
      ].join ' '

    it 'nice message with additionalProperties', ->
      nikita.call
        a_string: 'ok'
        lonely_duck: true
        schema:
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

    it 'ensure schema is an object', ->
      nikita.call
        schema: true
        handler: (->)
      .should.be.rejectedWith [
        'METADATA_SCHEMA_INVALID_VALUE:'
        'option `schema` expect an object literal value,'
        'got true in action `call`.'
      ].join ' '
      nikita
        schema: true
        handler: (->)
      .should.be.rejectedWith [
        'METADATA_SCHEMA_INVALID_VALUE:'
        'option `schema` expect an object literal value,'
        'got true in root action.'
      ].join ' '
  
  describe '$ref', ->

    it 'valid', ->
      nikita
      .registry.register ['test', 'schema'],
        schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      # Valid schema
      .call
        an_object: an_integer: 1234
        schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        handler: (->)

    it 'invalid', ->
      nikita
      .registry.register ['test', 'schema'],
        schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      .call
        an_object: an_integer: 'abc'
        schema:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema'
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        'registry://test/schema/properties/an_integer/type config.an_object.an_integer should be integer,'
        'type is "integer".'
      ].join ' '
  
  describe 'constructor', ->

    it 'useDefaults', ->
      nikita.call
        schema:
          type: 'object'
          properties:
            'a_string':
              type: 'string'
              default: 'a value'
        handler: ({config}) ->
          config.a_string.should.eql 'a value'

    it.skip 'coerceTypes', ->
      # Option is currently disactivated because it is unclear wether we shall
      # accept its rule or create ours. For exemple, `true` is cast to string `"true"`
      # and string `""` is cast to `null` which might not be what we want.
      nikita.call
        schema:
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
        schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        config:
          a_regexp: /.*/
        handler: ({config}) ->
          'ok'.should.match config.a_regexp

    it 'instanceof invalid', ->
      nikita.call
        relax: true
        schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        config:
          a_regexp: 'invalid'
        handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/properties/a_regexp/instanceof config.a_regexp should pass "instanceof" keyword validation,'
        'keyword is "instanceof".'
      ].join ' '
