
nikita = require '../../src'
session = require '../../src/session'
{tags} = require '../test'

return unless tags.api

describe 'hook on_options', ->
  
  it 'modify an option', ->
    nikita
    .call
      a_key: 'a value'
      on_options: ({options}) ->
        options.a_key = 'a new value'
    , ({options, cascade}) ->
      options.a_key.should.eql 'a new value'
    .promise()
      
  it 'called after conditions', ->
    nikita
    .call
      if: false
      on_options: ({options}) ->
        throw Error 'NoWay'
    , (->)
    .promise()
