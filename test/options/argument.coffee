
mecano = require '../../src'
test = require '../test'

describe 'options "argument"', ->

  scratch = test.scratch @

  it 'pass a string', (next) ->
    mecano()
    .registry.register 'catchme', (options) ->
      options.argument.should.eql 'gotit'
    .catchme 'gotit'
    .then next

  it 'pass an array of strings', (next) ->
    i = 0
    mecano()
    .registry.register 'catchme', (options, next) ->
      options.argument.should.eql switch i++
        when 0 then 'gotit'
        when 1 then 'gotu'
      next null, true
    .catchme ['gotit', 'gotu'], (err, status) ->
      status.should.be.true() unless err
    .then next
