
nikita = require '../../src'
{tags} = require '../test'
  
return tags.api

describe 'api proxy', ->

  it 'return undefined if property not registered', ->
    (nikita().invalid is undefined).should.be.true()

  it 'throw error when calling undefined function', ->
    ( ->
      nikita().invalid()
    ).should.throw 'nikita(...).invalid is not a function'

  it 'return false if property in session', ->
    ('invalid' in nikita()).should.be.false()
