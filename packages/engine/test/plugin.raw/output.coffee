
nikita = require '../../src'

describe 'plugin.raw.output', ->

  it 'leave `true` as is', ->
    nikita.call raw_output: true, -> true
    .should.be.resolvedWith true
      
  it 'leave `false` as is', ->
    nikita.call raw_output: true, -> true
    .should.be.resolvedWith true

  it 'leave `{}` as is', ->
    nikita.call -> {}
    .should.be.resolvedWith {}
  
  
