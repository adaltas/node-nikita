
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
    
    it '`addMetadata` shall detect changes', ->
      nikita (action) ->
        changed = action.tools.schema.addMetadata 'toto', type: 'boolean'
        changed.should.be.true()
        changed = action.tools.schema.addMetadata 'toto', type: 'boolean'
        changed.should.be.false()
    
    it '`addMetadata` with incorrect value', ->
      nikita key: 'value', $meta: 'invalid', (action) ->
        action.tools.schema.addMetadata 'meta', type: 'boolean'
        action.metadata.schema =
          config:
            type: 'object'
            properties: {}
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
    
    it '`addMetadata` with coercion', ->
      nikita key: 'value', $meta: 1, (action) ->
        action.tools.schema.addMetadata 'meta', type: 'boolean'
        action.metadata.schema =
          config:
            type: 'object'
            properties: {}
        error = await action.tools.schema.validate action
        should(error).be.undefined()
        action.metadata.meta.should.be.true()

    it '`validate` return error', ->
      nikita key: 'value', (action) ->
        action.metadata.schema =
          config:
            type: 'object'
            properties:
              key: type: 'integer'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  describe '$ref', ->
    
    it 'invalid ref definition', ->
      nikita
      .call
        $schema: config:
          type: 'object'
          properties:
            'an_object': $ref: 'malformed/uri'
        an_object: 'abc'
      , (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_MALFORMED_URI:'
        'uri must start with a valid protocol'
        'such as "module://" or "registry://",'
        'got "malformed/uri".'
      ].join ' '
    
    it 'invalid ref definition', ->
      nikita
      .registry.register ['test', 'schema'],
        metadata: schema: config:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      .call
        $schema: config:
          type: 'object'
          properties:
            'an_object': $ref: 'registry://test/schema#/definitions/config'
        $handler: (->)
        an_object: an_integer: 'abc'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        'registry://test/schema#/definitions/config/properties/an_integer/type'
        'config/an_object/an_integer should be integer,'
        'type is "integer".'
      ].join ' '
        
    it 'invalid protocol', ->
      nikita
      .call
        $schema: config:
          type: 'object'
          properties:
            'a_key': $ref: 'invalid://protocol'
        $handler: (->)
        a_key: true
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_UNSUPPORTED_PROTOCOL:'
        'the $ref instruction reference an unsupported protocol,'
        'got "invalid:".'
      ].join ' '
  
  describe '$ref relative with `#/definitions`', ->
  
    it 'valid', ->
      nikita
      .call
        $schema:
          config:
            type: 'object'
            properties:
              'a_source': $ref: '#/definitions/config/properties/a_target'
              'a_target': 
                type: 'object'
                properties:
                  'an_integer': type: 'integer'
                  'a_default': type: 'string', default: 'hello'
        a_source: an_integer: '123'
      , (action) ->
        action.config.should.eql
          a_source: an_integer: 123, a_default: 'hello'

  describe '$ref with `module:` protocol', ->

    it 'invalid ref location', ->
      nikita.call
        an_object: an_integer: 'abc'
        $schema: config:
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

    it 'valid ref location', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          target: "#{tmpdir}/a_module"
          content: '''
          module.exports = {
            metadata: {
              schema: {
                config: {
                  type: 'object',
                  properties: {
                    an_integer: { type: "integer" },
                    a_default: { type: "string", default: "hello" }
                  }
                }
              }
            },
            handler: () => 'ok'
          }
          '''
        # Valid schema
        {config} = await @call
          $schema:
            config:
              type: 'object'
              properties:
                'a_source': $ref: "module://#{tmpdir}/a_module#/definitions/config"
          a_source: an_integer: '123'
        , ({config}) -> config: config
        config.should.eql
          a_source: an_integer: 123, a_default: 'hello'
  
  describe '$ref with `registry:` protocol', ->

    it 'invalid ref location', ->
      nikita.call
        an_object: an_integer: 'abc'
        $schema: config:
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

    it 'valid ref location', ->
      nikita
      .registry.register ['test', 'schema'],
        metadata: schema:
          config:
            type: 'object'
            properties:
              'an_integer': type: 'integer'
              'a_default': type: 'string', default: 'hello'
        handler: (->)
      # Valid schema
      .call
        $schema:
          config:
            type: 'object'
            properties:
              'a_source': $ref: 'registry://test/schema#/definitions/config'
        a_source: an_integer: '123'
      , (action) ->
        action.config.should.eql
          a_source: an_integer: 123, a_default: 'hello'

    it 'invalid ref location', ->
      nikita.call
        $schema: config:
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
