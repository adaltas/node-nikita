
nikita = require '../../src'
test = require '../test'

describe 'api each', ->

  it 'over an array', ->
    data =[]
    nikita()
    .each ['a', 'b'], (options) ->
      @call -> data.push "#{options.key}"
    .each ['c', 'd'], (options, next) ->
      @call -> data.push "#{options.key}"
      @next next
    .call ->
      data.join(',').should.eql 'a,b,c,d'
    .promise()

  it 'over an object', ->
    data =[]
    nikita()
    .each {a: '1', b: '2'}, (options) ->
      @call -> data.push "#{options.key}:#{options.value}"
    .each {c: '3', d: '4'}, (options, next) ->
      @call -> data.push "#{options.key}:#{options.value}"
      @next next
    .call ->
      data.join(',').should.eql 'a:1,b:2,c:3,d:4'
    .promise()

  it 'validate 1st argument', ->
    data =[]
    nikita()
    .each 'a string', ((options) ->)
    .next (err) ->
      err.message.should.eql 'Invalid Argument: first argument must be an array or an object to iterate, got "a string"'
    .promise()
