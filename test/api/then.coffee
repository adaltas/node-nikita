
mecano = require '../../src'
domain = require 'domain'

describe 'api then', ->

  it 'throw error if no more element', (next) ->
    d = domain.create()
    d.run ->
      history = []
      mecano.then ->
        throw Error 'Catchme'
    d.on 'error', (err) ->
      err.message.should.eql 'Catchme'
      d.exit()
      next()

  it 'then without arguments', (next) ->
    history = []
    mecano
    .call -> history.push 'a'
    .then()
    .call -> history.push 'b'
    .then (err) ->
      history.should.eql ['a', 'b']
      next err



