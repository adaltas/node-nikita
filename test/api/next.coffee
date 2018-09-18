
domain = require 'domain'
nikita = require '../../src'
{tags, scratch} = require '../test'

return unless tags.api

describe 'api next', ->
  
  it 'throw error if no more element', (next) ->
    d = domain.create()
    d.run ->
      nikita.next ->
        throw Error 'Catchme'
    d.on 'error', (err) ->
      err.message.should.eql 'Catchme'
      d.exit()
      next()
  
  it 'provide status', ->
    nikita
    .call (_, callback) -> callback null, true
    .next (err, {status}) ->
      status.should.be.true()
    .call (_, callback) -> callback null, false
    .next (err, {status}) ->
      status.should.be.false()
    .promise()

  it 'without arguments', ->
    history = []
    nikita
    .call -> history.push 'a'
    .next()
    .call -> history.push 'b'
    .next () ->
      history.should.eql ['a', 'b']
    .promise()

  it 'throw error when next not defined', (next) ->
    d = domain.create()
    d.run ->
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        false
      .call ({}, next) ->
        next.property.does.not.exist
      .call ({}) ->
        next Error 'Shouldnt be called'
      , (err) ->
    d.on 'error', (err) ->
      err.name.should.eql 'TypeError'
      d.exit()
      next()
