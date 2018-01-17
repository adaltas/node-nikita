
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.mkdir', ->

  scratch = test.scratch @

  they 'a file to a directory', (ssh) ->
    nikita
      ssh: ssh
    .fs.mkdir
      target: "#{scratch}/a_directory"
    .file.assert
      target: "#{scratch}/a_directory"
      type: 'directory'
    .promise()
