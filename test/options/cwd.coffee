
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "cwd"', ->

  scratch = test.scratch @
  
  it 'is cascaded', ->
    history = []
    nikita
    .call cwd: "#{scratch}/a_dir", ->
      @call (options) ->
        options.cwd.should.eql "#{scratch}/a_dir"
    .promise()
  
