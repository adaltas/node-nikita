
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'action "options"', ->
    
  it 'declare at root', ->
    nikita
    .call a_key: 'a value',  ({options}) ->
      options.a_key.should.eql 'a value'
    .promise()
        
  it 'declare in options', ->
    nikita
    .call options: a_key: 'a value',  ({options}) ->
      options.a_key.should.eql 'a value'
    .promise()
  
