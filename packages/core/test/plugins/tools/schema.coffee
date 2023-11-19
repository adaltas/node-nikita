
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.schema', ->
  return unless test.tags.api
  
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
        action.metadata.definitions =
          config:
            type: 'object'
            properties: {}
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
    
    it '`addMetadata` with coercion', ->
      nikita key: 'value', $meta: 1, (action) ->
        action.tools.schema.addMetadata 'meta', type: 'boolean'
        action.metadata.definitions =
          config:
            type: 'object'
            properties: {}
        error = await action.tools.schema.validate action
        should(error).be.undefined()
        action.metadata.meta.should.be.true()
  
  describe '`validate` error with INVALID_DEFINITION', ->

    it 'root action', ->
      nikita (action) ->
        # Defining $ref in properties is invalid
        action.metadata.definitions =
          config:
            type: 'object'
            properties:
              $ref: 'module://@nikitajs/some/module'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_INVALID_DEFINITION'
        error.message.should.eql [
          'NIKITA_SCHEMA_INVALID_DEFINITION:'
          'schema failed to compile in root action, schema is invalid:'
          'data/definitions/config/properties/$ref must be object,boolean.'
        ].join ' '

    it 'call action', ->
      nikita.call (action) ->
        # Defining $ref in properties is invalid
        action.metadata.definitions =
          config:
            type: 'object'
            properties:
              $ref: 'module://@nikitajs/some/module'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_INVALID_DEFINITION'
        error.message.should.eql [
          'NIKITA_SCHEMA_INVALID_DEFINITION:'
          'schema failed to compile in action `call`, schema is invalid:'
          'data/definitions/config/properties/$ref must be object,boolean.'
        ].join ' '

    it 'call with action module', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          content: 'module.exports = {}'
          target: "#{tmpdir}/my_module.js"
        @call "#{tmpdir}/my_module.js", (action) ->
          # Defining $ref in properties is invalid
          action.metadata.definitions =
            config:
              type: 'object'
              properties:
                $ref: 'module://@nikitajs/some/module'
          error = await action.tools.schema.validate action
          error.code.should.eql 'NIKITA_SCHEMA_INVALID_DEFINITION'
          error.message = error.message.replace "#{tmpdir}/my_module.js", 'package/module'
          error.message.should.eql [
            'NIKITA_SCHEMA_INVALID_DEFINITION:'
            'schema failed to compile in action `call` in module package/module, schema is invalid:'
            'data/definitions/config/properties/$ref must be object,boolean.'
          ].join ' '

    
  describe '`validate` error with VALIDATION_CONFIG', ->

    it 'root action', ->
      nikita key: 'value', (action) ->
        # key is a string, let's define it as an integer
        action.metadata.definitions =
          config:
            type: 'object'
            properties:
              key: type: 'integer'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        error.message.should.eql [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of root action:'
          '#/definitions/config/properties/key/type config/key must be integer, type is "integer".'
        ].join ' '

    it 'call action', ->
      nikita.call key: 'value', (action) ->
        # key is a string, let's define it as an integer
        action.metadata.definitions =
          config:
            type: 'object'
            properties:
              key: type: 'integer'
        error = await action.tools.schema.validate action
        error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        error.message.should.eql [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `call`:'
          '#/definitions/config/properties/key/type config/key must be integer,'
          'type is "integer".'
        ].join ' '

    it 'call with action module', ->
      nikita
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.base.writeFile
          content: 'module.exports = {}'
          target: "#{tmpdir}/my_module.js"
        @call "#{tmpdir}/my_module.js", key: 'value', (action) ->
          # key is a string, let's define it as an integer
          action.metadata.definitions =
            config:
              type: 'object'
              properties:
                key: type: 'integer'
          error = await action.tools.schema.validate action
          error.code.should.eql 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          error.message = error.message.replace "#{tmpdir}/my_module.js", 'package/module'
          error.message.should.eql [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'one error was found in the configuration of action `call`'
            'in module package/module:'
            '#/definitions/config/properties/key/type config/key must be integer,'
            'type is "integer".'
          ].join ' '
