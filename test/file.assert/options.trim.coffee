
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'fs'

describe 'file.assert option trim', ->

  scratch = test.scratch @

  they 'trim source', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: '\nok\n'
    .file.assert
      target: "#{scratch}/a_file"
      content: 'ok'
      trim: true
    .promise()

  they 'trim content string', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'ok'
    .file.assert
      target: "#{scratch}/a_file"
      content: '\nok\n'
      trim: true
    .promise()

  they 'trim content buffer', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'ok'
    .file.assert
      target: "#{scratch}/a_file"
      content: Buffer.from '\nok\n'
      trim: true
    .promise()
