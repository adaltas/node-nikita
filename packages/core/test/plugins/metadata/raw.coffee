
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.raw', ->
  return unless tags.api

  describe 'plugins.metadata.raw', ->
    
    describe 'raw_input', ->
      
      it 'get default from `raw`', ->
        nikita
          $raw: true
        , ({metadata}) ->
          metadata.raw.should.be.true()
          metadata.raw_input.should.be.true()

      it 'argument is `true`', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw_input: true
            handler: ({config, args}) ->
              config: config
              args: args
        .an.action true
        .should.be.finally.match
          args: [true]
          config: {}
          
      it 'argument is `false`', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw_input: true
            handler: ({config, args}) ->
              config: config
              args: args
        .an.action false
        .should.be.finally.match
          args: [false]
          config: {}

      it 'no argument', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw_input: true
            handler: ({config, args}) ->
              config: config
              args: args
        .an.action()
        .should.be.finally.match
          args: []
          config: {}

      it 'argument is `{}`', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw_input: true
            handler: ({config, args}) ->
              config: config
              args: args
        .an.action {}
        .should.be.finally.match
          args: [{}]
          config: {}

      it 'multiple arguments', ->
        nikita ({registry}) ->
          await registry.register ['an', 'action'],
            metadata: raw_input: true
            handler: ({args, config}) ->
              args: args
              config: config
        .an.action 'an argument', a_key: 'a value'
        .should.be.finally.match
          args: ['an argument', a_key: 'a value']
          config: {}
          
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
    
    
