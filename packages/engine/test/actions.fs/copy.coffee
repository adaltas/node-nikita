
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.copy', ->

  they 'a file to a directory', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_file"
      content: 'some content'
    .fs.mkdir
      target: "{{parent.metadata.tmpdir}}/a_directory"
    .fs.copy
      source: "{{parent.metadata.tmpdir}}/a_file"
      target: "{{parent.metadata.tmpdir}}/a_directory"
    .fs.readFile
      target: "{{parent.metadata.tmpdir}}/a_directory/a_file"
    .should.be.finally.containEql 'some content'

  they 'a file to a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_source"
      content: 'some source content'
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_target"
      content: 'some target content'
    .fs.copy
      source: "{{parent.metadata.tmpdir}}/a_source"
      target: "{{parent.metadata.tmpdir}}/a_target"
    .fs.readFile
      target: "{{parent.metadata.tmpdir}}/a_target"
    .should.be.finally.containEql 'some source content'

  they 'option argument default to target', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_source"
      content: 'some content'
    .fs.copy "{{parent.metadata.tmpdir}}/a_target",
      source: "{{parent.metadata.tmpdir}}/a_source"
    .fs.readFile "{{parent.metadata.tmpdir}}/a_target"
    .should.be.finally.containEql 'some content'
