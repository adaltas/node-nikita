
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.exists', ->

  they 'does not exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.exists
      target: "{{parent.metadata.tmpdir}}/not_here"
    .should.be.resolvedWith false

  they 'exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_file"
      content: "some content"
    .fs.exists
      target: "{{parent.metadata.tmpdir}}/a_file"
    .should.be.resolvedWith true

  they 'option argument default to target', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_file"
      content: ''
    .fs.exists "{{parent.metadata.tmpdir}}/a_file"
    .should.be.resolvedWith true
