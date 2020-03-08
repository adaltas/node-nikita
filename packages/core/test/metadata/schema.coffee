
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "schema"', ->

  it 'is valid', ->
    nikita
    .call
      a_string: 'a value'
      an_integer: 1
      schema:
        type: 'object'
        properties:
          'a_string': type: 'string'
          'an_integer': type: 'integer', minimum: 1
    , ({options}) ->
      options.a_string.should.be.a.String()
      options.an_integer.should.be.a.Number()
    .promise()

  it 'invalid with one error', ->
    nikita
    .call
      a_string: 1
      an_integer: 0
      schema:
        type: 'object'
        properties:
          'an_integer': type: 'integer', 'minimum': 1
      relax: true
    , (->)
    , (err) ->
      err.message.should.eql 'data.an_integer should be >= 1'
      (err.errors is undefined).should.be.true()
    .promise()

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
      relax: true
    , (->)
    , (err) ->
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
    .promise()
  
  describe '$ref', ->

    it 'instance and namespace as an array', ->
      nikita()
      .registry.register ['test', 'schema'],
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

    it 'instance and namespace as an object', ->
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

    it 'global and namespace as an array', ->
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

  it 'gobal and namespace as an object', ->
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

    it 'useDefaults', ->
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

    it 'instanceof', ->
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
