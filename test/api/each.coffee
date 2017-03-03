
nikita = require '../../src'
test = require '../test'

describe 'api each', ->

  it 'over an array', (next) ->
    data =[]
    nikita()
    .each ['a', 'b'], (options) ->
      @call -> data.push "#{options.key}"
      @then next
    .each ['c', 'd'], (options, next) ->
      @call -> data.push "#{options.key}"
      @then next
    .then (err) ->
      data.join(',').should.eql 'a,b,c,d' unless err
      next err

  it 'over an object', (next) ->
    data =[]
    nikita()
    .each {a: '1', b: '2'}, (options) ->
      @call -> data.push "#{options.key}:#{options.value}"
    .each {c: '3', d: '4'}, (options, next) ->
      @call -> data.push "#{options.key}:#{options.value}"
      @then next
    .then (err) ->
      data.join(',').should.eql 'a:1,b:2,c:3,d:4' unless err
      next err

  it 'validate 1st argument', (next) ->
    data =[]
    nikita()
    .each 'a string', ((options) ->)
    .then (err) ->
      err.message.should.eql 'Invalid Argument: first argument must be an array or an object to iterate, got "a string"'
      next()
