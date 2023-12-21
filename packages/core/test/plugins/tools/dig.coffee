
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.tools.dig', ->
  return unless test.tags.api

  it 'root action', ->
    nikita a_key: 'a value', ({tools: {dig}}) ->
      dig (action) ->
        action.config.a_key
      .should.be.resolvedWith ['a value']

  it 'traverse the parent hierarchy', ->
    nikita.call a_key: 1, ->
      @call a_key: 2, ->
        @call a_key: 3, ({tools: {dig}}) ->
          dig ({config}) ->
            config.a_key
          .should.be.resolvedWith [3, 2, 1]

  it 'traverse siblings', ->
    nikita.call a_key: 1, ->
      await @call a_key: 2, (->)
      await @call a_key: 3, ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith [3, 2, 1]

  it 'traverse siblings children', ->
    nikita.call a_key: '1', ->
      await @call a_key: '2', ->
        await @call a_key: '3', (->)
      await @call a_key: '4', ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith ['4', '3', '2', '1']

  it 'traverse siblings children', ->
    nikita.call a_key: 1, ->
      await @call a_key: 2, ->
      await @call a_key: 3, ->
        await @call (->)
        await @call a_key: 4, ->
          await @call a_key: 5, (->)
          await @call a_key: 6, (->)
        await @call (->)
        await @call a_key: 7, (->)
      await @call a_key: 8, ->
      await @call a_key: 9, ({tools: {dig}}) ->
        dig ({config}) ->
          config.a_key
        .should.be.resolvedWith [9, 8, 7, 6, 5, 4, 3, 2, 1]
