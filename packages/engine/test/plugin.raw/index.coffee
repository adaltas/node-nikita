
nikita = require '../../src'

describe 'plugin.raw', ->

  it 'pass `true` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({options}) -> options
    .an.action true
    .should.be.resolvedWith [true]
      
  it 'pass `false` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({options}) -> options
    .an.action false
    .should.be.resolvedWith [false]

  it 'pass `{}` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({options}) -> options
    .an.action {}
    .should.be.resolvedWith [{}]
