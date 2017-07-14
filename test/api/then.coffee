
domain = require 'domain'
test = require '../test'
nikita = require '../../src'

describe 'api then', ->

  scratch = test.scratch @
  
  it 'throw error if no more element', (next) ->
    d = domain.create()
    d.run ->
      nikita.then ->
        throw Error 'Catchme'
    d.on 'error', (err) ->
      err.message.should.eql 'Catchme'
      d.exit()
      next()

  it 'then without arguments', ->
    history = []
    nikita
    .call -> history.push 'a'
    .then()
    .call -> history.push 'b'
    .then (err) ->
      history.should.eql ['a', 'b']
    .promise()

  it 'throw error when then not defined', (next) ->
    d = domain.create()
    d.run ->
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        false
      .call (options, next) ->
        next.property.does.not.exist
      .call (options) ->
        next Error 'Shouldnt be called'
      , (err) ->
    d.on 'error', (err) ->
      err.name.should.eql 'TypeError'
      d.exit()
      next()
