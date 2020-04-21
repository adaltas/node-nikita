
nikita = require '../../src'
utils = require '../../src/utils'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'fs.unlink', ->

  they 'a file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    .fs.writeFile
      target: "{{parent.metadata.tmpdir}}/a_target"
      content: 'hello'
    .fs.unlink
      target: "{{parent.metadata.tmpdir}}/a_target"
    .fs.exists
      target: "{{parent.metadata.tmpdir}}/a_target"
    .should.be.resolvedWith false
