
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "argument"', ->

  it 'pass a string', ->
    nikita()
    .registry.register 'catchme', ({options}) ->
      options.argument.should.eql 'gotit'
    .catchme 'gotit'
    .promise()

  it 'pass an array of strings', ->
    i = 0
    nikita()
    .registry.register 'catchme', ({options}, next) ->
      options.argument.should.eql switch i++
        when 0 then 'gotit'
        when 1 then 'gotu'
      next null, true
    .catchme ['gotit', 'gotu'], (err, {status}) ->
      status.should.be.true() unless err
    .promise()
