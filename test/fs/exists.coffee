
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.exists', ->

  scratch = test.scratch @

  they 'does not exists', (ssh) ->
    nikita
      ssh: ssh
    .fs.exists
      target: "#{scratch}/not_here"
    , (err, exists) ->
      throw err if err
      exists.should.be.false()
    .promise()

  they 'exists', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: "some content"
    .fs.exists
      target: "#{scratch}/a_file"
    , (err, exists) ->
      throw err if err
      exists.should.be.true()
    .promise()
