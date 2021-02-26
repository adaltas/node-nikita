
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.raw', ->
  return unless tags.api

  describe 'input', ->
    
    describe 'registry', ->

      it 'pass `true` as is', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'], raw_input: true, handler: ({args}) -> args
        .an.action true
        .should.be.resolvedWith [true]
          
      it 'pass `false` as is', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'], raw_input: true, handler: ({args}) -> args
        .an.action false
        .should.be.resolvedWith [false]

      it 'pass `{}` as is', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'], raw_input: true, handler: ({args}) -> args
        .an.action {}
        .should.be.resolvedWith [{}]

      it 'config is empty', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw: true
            handler: ({config}) -> config
        .an.action 'an argument'
        .should.be.resolvedWith {}
          
    describe 'arguments', ->
      
      it 'pass `true` as is', ->
        nikita true, $raw_input: true, (action) ->
          config: action.config
          argument: action.metadata.argument
        .should.be.finally.containEql
          config: {}
          argument: true
          $status: false

  describe 'output', ->

    it 'leave `true` as is', ->
      nikita.call $raw_output: true, -> true
      .should.be.resolvedWith true
        
    it 'leave `false` as is', ->
      nikita.call $raw_output: true, -> true
      .should.be.resolvedWith true

    it 'leave `{}` as is', ->
      nikita.call $raw_output: true,-> {}
      .should.be.resolvedWith {}
    
    
