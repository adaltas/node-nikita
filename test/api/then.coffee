
mecano = require '../../src'
domain = require 'domain'

describe 'api callback', ->

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



