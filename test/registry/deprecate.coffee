
mecano = require '../../src'
test = require '../test'
each = require 'each'

describe 'registry.deprecate', ->

  scratch = test.scratch @

  it 'function handler without new name', (next) ->
    mecano
    .call ->
      mecano.deprecate 'my_function', -> 'my_function'
    .call (_, next) ->
      mecano
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated'
      .then next
    .call ->
      mecano.unregister 'my_function'
    .then next

  it 'function handler with new name', (next) ->
    mecano
    .call ->
      mecano.deprecate 'my_function', 'my_new_function', -> 'my_function'
    .call (_, next) ->
      mecano
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .then next
    .call ->
      mecano.unregister 'my_function'
    .then next

  it 'string handler without new name', (next) ->
    mecano
    .call ->
      mecano.deprecate 'my_function', 'mecano/file/touch'
    .call (_, next) ->
      mecano
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use mecano/file/touch'
      .then next
    .call ->
      mecano.unregister 'my_function'
    .then next

  it 'string handler with new name', (next) ->
    mecano
    .call ->
      mecano.deprecate 'my_function', 'my_new_function', 'mecano/file/touch'
    .call (_, next) ->
      mecano
      .my_function relax: true, (err) ->
        err.message.should.eql 'my_function is deprecated, use my_new_function'
      .then next
    .call ->
      mecano.unregister 'my_function'
    .then next
