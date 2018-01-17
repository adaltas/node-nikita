
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'fs.writeFile', ->

  scratch = test.scratch @

  they 'content is a string', (ssh) ->
    nikita
      ssh: ssh
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'some content'
    .file.assert
      target: "#{scratch}/a_file"
      content: 'some content'
    .promise()

  they 'content is empty', (ssh) ->
    nikita
      ssh: ssh
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: ''
    .file.assert
      target: "#{scratch}/a_file"
      content: ''
    .promise()
  
  they 'option append on missing file', (ssh) ->
    nikita
      ssh: ssh
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'some content'
      flags: 'a'
    .file.assert
      target: "#{scratch}/a_file"
      content: 'some content'
    .promise()
  
  they 'option append on existing file', (ssh) ->
    nikita
      ssh: ssh
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'some'
    .fs.writeFile
      target: "#{scratch}/a_file"
      content: 'thing'
      flags: 'a'
    .file.assert
      target: "#{scratch}/a_file"
      content: 'something'
    .promise()
