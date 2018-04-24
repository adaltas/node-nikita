
nikita = require '../../src'
they = require 'ssh2-they'
fs = require 'ssh2-fs'
test = require '../test'

describe 'fs.createWriteStream', ->

  scratch = test.scratch @

  they 'write a file', (ssh) ->
    buffers = []
    nikita
      ssh: ssh
    .fs.createWriteStream
      target: "#{scratch}/a_file"
      stream: (ws) ->
        ws.write 'hello'
        ws.end()
    .file.assert
      target: "#{scratch}/a_file"
      content: 'hello'
    .promise()
  
