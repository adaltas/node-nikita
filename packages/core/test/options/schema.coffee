
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
      err.errors.map( (err) -> "#{err.property} #{err.message}").should.eql [
        'instance.a_string is not of a type(s) string'
      ,
        'instance.an_integer must have a minimum value of 1'
      ]
    .promise()
