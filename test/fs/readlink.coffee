
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.readlink', ->

  scratch = test.scratch @

  they 'get value', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_source"
    .fs.symlink
      target: "#{scratch}/a_target"
      source: "#{scratch}/a_source"
    .fs.readlink
      target: "#{scratch}/a_target"
    , (err, target) ->
      target.should.eql "#{scratch}/a_source"
    .promise()
