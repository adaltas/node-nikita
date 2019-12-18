
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "schema"', ->

  it 'is valid', ->
    nikita
    .call
      a_string: 'a value'
      an_integer: 1
      schema:
        'id': '/SimplePerson'
        'type': 'object'
        'properties':
          'a_string': 'type': 'string'
          'an_integer': 'type': 'integer', 'minimum': 1
    , ({options}) ->
      options.a_string.should.be.a.String()
      options.an_integer.should.be.a.Number()
    .promise()

  it 'is invalid', ->
    nikita
    .call
      a_string: 1
      an_integer: 0
      schema:
        'type': 'object'
        'properties':
          'a_string': 'type': 'string'
          'an_integer': 'type': 'integer', 'minimum': 1
      relax: true
    , (->)
    , (err) ->
      err.message.should.eql 'Invalid Options'
      err.errors.map( (err) -> err.message).should.eql [
        'data.a_string should be string'
      ,
        'data.an_integer should be >= 1'
      ]
    .promise()

  it 'schema ref inside nikita instance', ->
    nikita()
    .registry.register ['test', 'schema'],
      schema:
        'type': 'object'
        'properties':
          'a_string': 'type': 'string'
      handler: (->)
    .call
      split: a_string: 'a value'
      schema:
        'type': 'object'
        'properties':
          'split': "$ref": "/nikita/test/schema"
      relax: true
    , (->)
    , (err) ->
      throw err if err
    .call
      split: a_string: 1
      schema:
        'type': 'object'
        'properties':
          'split': "$ref": "/nikita/test/schema"
      relax: true
    , (->)
    , (err) ->
      err.message.should.eql 'Invalid Options'
      err.errors.map( (err) -> err.message).should.eql [
        'data.split.a_string should be string'
      ]
    .promise()
