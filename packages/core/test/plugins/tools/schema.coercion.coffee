
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.schema.coercion', ->
  return unless test.tags.api

  describe 'integer', ->

    it 'from string', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string':
                type: ['number', 'string']
                coercion: true
        from_string: '123'
      , ({config}) ->
        config.from_string.should.eql 123

  describe 'number', ->

    it 'from string', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string':
                type: ['number', 'string']
                coercion: true
        from_string: '1.23'
      , ({config}) ->
        config.from_string.should.eql 1.23

    it 'from string (invalid)', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string':
                type: ['number', 'string']
                coercion: true
        from_string: 'abc'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        '#/definitions/config/properties/from_string/coercion config/from_string'
        'fail to convert string to number,'
        'value is "abc".'
      ].join(' ')

    it 'dont conflict with object', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_object':
                type: ['number', 'object']
                coercion: true
        from_object: {key: 'value'}
      , ({config}) ->
        config.from_object.should.eql {key: 'value'}

  describe 'string', ->

    it 'from boolean', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_boolean_false':
                type: ['string', 'boolean']
                coercion: true
              'from_boolean_true':
                type: ['string', 'boolean']
                coercion: true
        from_boolean_false: false
        from_boolean_true: true
      , ({config}) ->
        config.from_boolean_false.should.eql ''
        config.from_boolean_true.should.eql '1'

    it 'from integer and number', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_integer':
                type: ['string', 'integer']
                coercion: true
              'from_number':
                type: ['string', 'number']
                coercion: true
        from_integer: 123
        from_number: 1.23
      , ({config}) ->
        config.from_integer.should.eql '123'
        config.from_number.should.eql '1.23'

    it 'dont conflict with instanceof', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              from_string:
                oneOf: [
                  "type": ["string", "number"]
                  "coercion": true
                ,
                  "instanceof": "Buffer"
                ]
        from_string: 'ok'
      , ({config}) ->
        config.from_string.should.eql 'ok'

  describe 'boolean', ->

    it 'from string', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string_empty':
                type: ['boolean', 'string']
                coercion: true
              'from_string_filled':
                type: ['boolean', 'string']
                coercion: true
        from_string_empty: ''
        from_string_filled: 'ok'
      , ({config}) ->
        config.from_string_empty.should.be.false()
        config.from_string_filled.should.be.true()

    it 'from number', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_number_0':
                type: ['boolean', 'number']
                coercion: true
              'from_number_1':
                type: ['boolean', 'number']
                coercion: true
        from_number_0: 0
        from_number_1: 1
      , ({config}) ->
        config.from_number_0.should.be.false()
        config.from_number_1.should.be.true()

    it 'from array (invalid)', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_array':
                type: ['boolean', 'array']
                coercion: true
        from_array: [0]
      , ({config}) ->
        config.from_array.should.eql [0]

  describe 'array', ->

    it 'from string and object', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string_empty':
                type: ['array', 'string']
                coercion: true
              'from_string_filled':
                type: ['array', 'string']
                coercion: true
              'from_object':
                type: ['array', 'object']
                coercion: true
        from_string_empty: ''
        from_string_filled: 'ok'
        from_object: {key: 'value'}
      , ({config}) ->
        config.from_string_empty.should.eql ['']
        config.from_string_filled.should.eql ['ok']
        config.from_object.should.eql [ {key: 'value'} ]

    it 'array shouldnt be altered', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_array':
                type: ['array']
                coercion: true
        from_array: ['ok']
      , ({config}) ->
        config.from_array.should.eql ['ok']

    it 'forward coerced value to items', ->
      nikita
        $definitions:
          config:
            type: 'object'
            properties:
              'from_string':
                type: ['array', 'string']
                coercion: true
                items:
                  type: [
                    "string"
                    "integer"
                  ]
                  filemode: true
        from_string: '744'
      , ({config}) ->
        config.from_string.should.eql [ 0o0744 ]
