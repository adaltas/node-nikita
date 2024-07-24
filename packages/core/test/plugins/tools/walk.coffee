
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.walk', ->
  return unless test.tags.api

  it 'start in current action', ->
    nikita.call a_key: 'a value', ({ tools: { walk } }) ->
      walk (action) ->
        action.config.a_key
      .should.be.resolvedWith ['a value']

  it 'start traverse the parent hierarchy', ->
    nikita.call a_key: '1', ->
      @call a_key: '2', ->
        @call a_key: '3', ({ tools: { walk } }) ->
          walk ({config}) ->
            config.a_key
          .should.be.resolvedWith ['3', '2', '1']

  it 'starting from parent action', ->
    nikita.call a_key: '1', ->
      @call -> @call -> @call -> @call a_key: '2', ({ parent, tools: { walk }}) ->
        walk parent.parent, ({config}) ->
          config.a_key
        .should.be.resolvedWith ['1']

  it 'skip undefined returned value', ->
    nikita.call a_key: '1', ->
      @call -> @call -> @call -> @call a_key: '2', ({ tools: { walk } }) ->
        walk ({config}) ->
          config.a_key
        .should.be.resolvedWith ['2', '1']

    
