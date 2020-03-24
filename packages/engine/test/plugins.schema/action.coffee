
nikita = require '../../src'

describe 'plugin.schema.action', ->

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

  it 'is valid', ->
    nikita ->
      {a_string, an_integer} = await @call
        a_string: 'a value'
        an_integer: 1
        schema:
          type: 'object'
          properties:
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
        handler: ({options}) -> options
      a_string.should.be.a.String()
      an_integer.should.be.a.Number()

  it 'invalid with one error', ->
    nikita
    .call
      a_string: 1
      an_integer: 0
      schema:
        type: 'object'
        properties:
          'an_integer': type: 'integer', 'minimum': 1
      handler: (->)
    .catch (err) ->
      err.message.should.eql 'data.an_integer should be >= 1'

  it 'invalid with multiple errors', ->
    nikita
    .call
      a_string: 1
      an_integer: 0
      schema:
        type: 'object'
        properties:
          'a_string': type: 'string'
          'an_integer': type: 'integer', 'minimum': 1
      handler: ->
    .catch (err) ->
      err.message.should.eql """
      Invalid Options: got 2 errors
      data.a_string should be string
      data.an_integer should be >= 1
      """
      err.errors.map( (err) -> err.message).should.eql [
        'data.a_string should be string'
      ,
        'data.an_integer should be >= 1'
      ]
  
  describe '$ref', ->

    it 'instance and namespace as an array', ->
      n = nikita
      n.registry.register ['test', 'schema'],
        schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      # Valid schema
      n.call
        split: an_integer: 1234
        schema:
          type: 'object'
          properties:
            'split': $ref: 'registry://test/schema'
        handler: (->)
      # Invalid schema
      n.call
        split: an_integer: 'abc'
        schema:
          type: 'object'
          properties:
            'split': $ref: 'registry://test/schema'
        handler: (->)
      .then ->
        throw Error 'Error not thrown as expected'
      .catch (err) ->
        err.message.should.eql 'data.split.an_integer should be integer'

    it.skip 'instance and namespace as an object', ->
      # Currently disabled, didn't investigate why
      nikita()
      .registry.register
        'test':
          'schema':
            schema:
              type: 'object'
              properties:
                'an_integer': type: 'integer'
            handler: (->)
      .call
        split: an_integer: 1234
        schema:
          type: 'object'
          properties:
            'split': $ref: '/nikita/test/schema'
        relax: true
      , (->)
      , (err) ->
        throw err if err
      .call
        split: an_integer: 'abc'
        schema:
          type: 'object'
          properties:
            'split': $ref: '/nikita/test/schema'
        relax: true
      , (->)
      , (err) ->
        err.message.should.eql 'data.split.an_integer should be integer'
      .promise()

    it.skip 'global and namespace as an array', ->
      nikita.registry.register ['test', 'schema'],
        schema:
          type: 'object'
          properties:
            'an_integer': type: 'integer'
        handler: (->)
      await nikita()
      .call
        split: an_integer: 1234
        schema:
          type: 'object'
          properties:
            'split': $ref: '/nikita/test/schema'
        relax: true
      , (->)
      , (err) ->
        throw err if err
      .call
        split: an_integer: 'abc'
        schema:
          type: 'object'
          properties:
            'split': $ref: '/nikita/test/schema'
        relax: true
      , (->)
      , (err) ->
        err.message.should.eql 'data.split.an_integer should be integer'
      .promise()
    nikita.registry.unregister ['test', 'schema']

  it.skip 'gobal and namespace as an object', ->
    nikita.registry.register
      'test':
        'schema':
          schema:
            type: 'object'
            properties:
              'an_integer': type: 'integer'
          handler: (->)
    await nikita()
    .call
      split: an_integer: 1234
      schema:
        type: 'object'
        properties:
          'split': $ref: '/nikita/test/schema'
      relax: true
    , (->)
    , (err) ->
      throw err if err
    .call
      split: an_integer: 'abc'
      schema:
        type: 'object'
        properties:
          'split': $ref: '/nikita/test/schema'
      relax: true
    , (->)
    , (err) ->
      err.message.should.eql 'data.split.an_integer should be integer'
    .promise()
    nikita.registry.unregister ['test', 'schema']
  
  describe 'constructor', ->

    it.skip 'useDefaults', ->
      nikita()
      .call
        schema:
          type: 'object'
          properties:
            'a_string':
              type: 'string'
              default: 'a value'
      , ({options}) ->
        options.a_string.should.eql 'a value'
      .promise()

    it.skip 'coerceTypes', ->
      # Option is currently disactivated because it is unclear wether we shall
      # accept its rule or create ours. For exemple, `true` is cast to string `"true"`
      # and string `""` is cast to `null` which might not be what we want.
      nikita()
      .call
        schema:
          type: 'object'
          properties:
            'int_to_string':
              type: 'string'
            'string_to_boolean':
              type: 'boolean'
      ,
        int_to_string: 1234
        string_to_boolean: ''
      , ({options}) ->
        options.int_to_string.should.eql '1234'
        options.string_to_boolean.should.be.false()
      .promise()
  
  describe 'ajv-keywords', ->

    it.skip 'instanceof', ->
      nikita()
      .call
        schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        options:
          a_regexp: /.*/
      , ({options}) ->
        'ok'.should.match options.a_regexp
      .call
        relax: true
        schema:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        options:
          a_regexp: 'invalid'
      , (->), (err) ->
        err.message.should.eql 'data.a_regexp should pass "instanceof" keyword validation'
      .promise()
