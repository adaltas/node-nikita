
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise options', ->

  scratch = test.scratch @

  it 'global dont overwrite local options', (next) ->
    m = mecano
      global_param: true
    m.propagated_options.push 'parent_param_propagated'
    m.register 'achild', (options, callback) ->
      options.local_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      (options.parent_param_unpropagated is undefined).should.be.true()
      options.global_param.should.be.true()
      callback null, true
    m.register 'aparent', (options, callback) ->
      options.global_param.should.be.true()
      options.parent_param_propagated.should.be.true()
      options.parent_param_unpropagated.should.be.true()
      @achild
        local_param: true
      .then (err, status) -> callback err, true
    m.aparent
      parent_param_propagated: true
      parent_param_unpropagated: true
    .then next

  it 'accept empty array', (next) ->
    mecano
    .call [], (options, callback) ->
      callback null, true
    .write []
    .then next



