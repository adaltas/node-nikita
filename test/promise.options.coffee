
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
      # local_param: true
      parent_param_propagated: true
      parent_param_unpropagated: true
    .then next

    # old test, we can remove this safely
    # it.only 'global dont overwrite local options', (next) ->
    #   logs_global = []
    #   logs_local = []
    #   log_global = (msg) -> console.log 'global'; logs_global.push msg
    #   log_local = (msg) -> console.log 'local'; logs_local.push msg
    #   mecano log: log_global
    #   .write
    #     destination: "#{scratch}/file_1"
    #     content: 'abc'
    #     log: log_local
    #   .write
    #     destination: "#{scratch}/file_1"
    #     content: 'def'
    #     append: true
    #     log: log_local
    #   .then (err, changed) ->
    #     return next err if err
    #     console.log logs_local
    #     logs_global.length.should.eql 0
    #     logs_local.length.should.be.above 1
    #     next()