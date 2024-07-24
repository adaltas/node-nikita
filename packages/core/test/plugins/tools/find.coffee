
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.find', ->
  return unless test.tags.api
  
  describe 'discovery', ->

    it 'start in current action', ->
      nikita.call a_key: 'a value', ({ tools: { find } }) ->
        find (action) ->
          action.config.a_key
        .should.be.resolvedWith 'a value'

    it 'traverse the parent hierarchy', ->
      nikita.call a_key: 'a value', ->
        @call ({ tools: { find } }) ->
          count = 0
          find (action) ->
            count++
            return unless action.config.a_key
            a_key: action.config.a_key, depth: action.metadata.depth
          .should.be.resolvedWith a_key: 'a value', depth: 1
          .then -> count.should.eql 2

    it 'traverse from parent', ->
      nikita.call a_key: 'a value', ->
        @call -> @call -> @call -> @call ({ parent, tools: { find } }) ->
          count = 0
          find parent.parent, (action) ->
            count++
            return unless action.config.a_key
            a_key: action.config.a_key, depth: action.metadata.depth
          .should.be.resolvedWith a_key: 'a value', depth: 1
          .then -> count.should.eql 3

  describe 'usage', ->
    
    it 'return the first value found', ->
      nikita
      .call key: '1', stop: true, ->
        @call key: '1.1', stop: true, ->
          @call key: '1.1.1', ({ tools: { find } }) ->
            find ({config}) ->
              config.key if config.stop
            .should.be.resolvedWith '1.1'
    
    it 'null is interpreted as a value', ->
      nikita
      .call key: '1', stop: true, ->
        @call key: null, stop: true, ->
          @call key: '1.1.1', ({ tools: { find } }) ->
            find ({config}) ->
              config.key if config.stop
            .should.be.resolvedWith null
    
    it 'fix bug where internal action variable was mutated', ->
      nikita.call key: 'depth 0', ->
        @call key: 'depth 1', ->
          @call key: 'depth 2', ({parent, tools: {find}}) ->
            await find parent, ({config}) -> true
            {key} = await find ({config}) -> config
            key.should.eql 'depth 2'
        
      
    
    
