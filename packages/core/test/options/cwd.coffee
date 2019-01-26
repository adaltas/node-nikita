
nikita = require '../../src'
test = require '../test'
{tags, scratch} = require '../test'

return unless tags.api

describe 'options "cwd"', ->
  
  it 'is cascaded', ->
    history = []
    nikita
    .call cwd: "#{scratch}/a_dir", ->
      @call ({options}) ->
        options.cwd.should.eql "#{scratch}/a_dir"
    .promise()
  
