
{tags} = require '../test'
nikita = require '../../src'

describe 'actions.status', ->
  return unless tags.api

  it 'get `-1`', ->
    nikita
    .call -> false
    .call -> true
    .status(-1)
    .should.be.resolvedWith true

  it 'get `0`', ->
    nikita
    .call -> true
    .call -> false
    .status(0)
    .should.be.resolvedWith true

  it 'get `undefined` with status `true`', ->
    nikita
    .call -> false
    .call -> true
    .call -> false
    .status()
    .should.be.resolvedWith true

  it 'get `undefined` with status `false`', ->
    nikita
    .call -> false
    .call -> false
    .status()
    .should.be.resolvedWith false
