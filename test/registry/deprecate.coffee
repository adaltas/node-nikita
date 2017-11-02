
nikita = require '../../src'
test = require '../test'

describe 'registry.deprecate', ->

  scratch = test.scratch @

  it 'function handler without new name', ->
    nikita
    .call ->
      nikita.deprecate 'my_function', -> 'my_function'
    .call (_, next) ->
      nikita
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated'
      .then next
    .call ->
      nikita.unregister 'my_function'
    .promise()

  it 'function handler with new name', ->
    nikita
    .call ->
      nikita.deprecate 'my_function', 'my_new_function', -> 'my_function'
    .call (_, next) ->
      nikita
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .then next
    .call ->
      nikita.unregister 'my_function'
    .promise()

  it 'string handler without new name', ->
    nikita
    .call ->
      nikita.deprecate 'my_function', 'nikita/file/touch'
    .call (_, next) ->
      nikita
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use nikita/file/touch'
      .then next
    .call ->
      nikita.unregister 'my_function'
    .promise()

  it 'string handler with new name', ->
    nikita
    .call ->
      nikita.deprecate 'my_function', 'my_new_function', 'nikita/file/touch'
    .call (_, next) ->
      nikita
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .then next
    .call ->
      nikita.unregister 'my_function'
    .promise()
