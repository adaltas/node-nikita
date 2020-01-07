
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'action "metadata"', ->
    
  it 'declare at root', ->
    nikita
    .call relax: true,  ({metadata}) ->
      metadata.relax.should.be.true()
    .promise()
        
  it 'declare in options', ->
    nikita
    .call metadata: relax: true,  ({metadata}) ->
      metadata.relax.should.be.true()
    .promise()
  
