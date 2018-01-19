
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.symlink', ->

  scratch = test.scratch @

  they 'create', (ssh) ->
    nikita
      ssh: ssh
    .file.touch
      target: "#{scratch}/a_source"
    .fs.symlink
      target: "#{scratch}/a_target"
      source: "#{scratch}/a_source"
    .file.assert
      target: "#{scratch}/a_target"
      filetype: 'symlink'
    .promise()
