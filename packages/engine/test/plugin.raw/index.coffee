
nikita = require '../../src'

describe 'plugin.raw', ->

  it 'pass `true` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({config}) -> config
    .an.action true
    .should.be.resolvedWith [true]
      
  it 'pass `false` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({config}) -> config
    .an.action false
    .should.be.resolvedWith [false]

  it 'pass `{}` as is', ->
    nikita ({registry}) ->
      await registry.register ['an', 'action'], raw: true, handler: ({config}) -> config
    .an.action {}
    .should.be.resolvedWith [{}]
