
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "domain"', ->

  scratch = test.scratch @

  it.skip 'synchronous', ->
    # Implementation not yet started
    n = nikita
    result = n.call
      get: true
      handler: ->
        return 'get me'
    console.log result
