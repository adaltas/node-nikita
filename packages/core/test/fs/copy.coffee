
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'fs.copy', ->

  they 'a file to a directory', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_file"
      content: 'some content'
    .system.mkdir
      target: "#{scratch}/a_directory"
    .fs.copy
      source: "#{scratch}/a_file"
      target: "#{scratch}/a_directory"
    .file.assert
      target: "#{scratch}/a_directory/a_file"
      content: 'some content'
    .promise()

  they 'a file to a file', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/a_source"
      content: 'some source content'
    .file
      target: "#{scratch}/a_target"
      content: 'some target content'
    .fs.copy
      source: "#{scratch}/a_source"
      target: "#{scratch}/a_target"
    .file.assert
      target: "#{scratch}/a_target"
      content: 'some source content'
    .promise()

  they 'option argument default to target', ({ssh}) ->
    nikita
      ssh: ssh
    .file.touch "#{scratch}/a_source"
    .fs.copy "#{scratch}/a_target",
      source: "#{scratch}/a_source"
    .file.assert "#{scratch}/a_target"
    .promise()
